# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonographIndexer do
  describe 'indexing a monograph' do
    subject { indexer.generate_solr_document }

    let(:indexer) { described_class.new(monograph) }
    let(:monograph) {
      build(:monograph,
            title: ['"Blah"-de-blah-blah and Stuff!'],
            creator: ["Moose, Bullwinkle\nSquirrel, Rocky"],
            description: ["This is the abstract"],
            date_created: ['c.2018?'],
            isbn: ['978-0-252012345 (paper)', '978-0252023456 (hardcover)', '978-1-62820-123-9 (e-book)'])
    }
    let(:file_set) { create(:file_set) }
    let(:press_name) { Press.find_by(subdomain: monograph.press).name }

    before do
      monograph.ordered_members << file_set
      monograph.save!
    end

    it 'indexes the ordered members' do
      expect(subject['ordered_member_ids_ssim']).to eq [file_set.id]
    end

    it 'indexes the press name' do
      expect(subject['press_name_ssim']).to eq press_name
    end

    it 'indexes the representative_id' do
      expect(subject['representative_id_ssim']).to eq monograph.representative_id
    end

    it 'has a single-valued, downcased-and-cleaned-up title to sort by' do
      expect(subject['title_si']).to eq 'blah-de-blah-blah and stuff'
    end

    it "indexes all creators' names for access/search and faceting" do
      expect(subject['creator_tesim']).to eq ['Moose, Bullwinkle', 'Squirrel, Rocky'] # access/search
      expect(subject['creator_sim']).to eq ['Moose, Bullwinkle', 'Squirrel, Rocky'] # facet
    end

    it "indexes first creator's name for access/search and (normalized) for sorting" do
      expect(subject['creator_full_name_tesim']).to eq 'Moose, Bullwinkle' # access/search
      expect(subject['creator_full_name_si']).to eq 'moose bullwinkle' # facet
    end

    it 'has description indexed by Hyrax::IndexesBasicMetadata' do
      expect(subject['description_tesim'].first).to eq 'This is the abstract'
    end

    it 'has a single-valued, cleaned-up date_created value to sort by' do
      expect(subject['date_created_si']).to eq '2018'
    end

    # 'isbn_numeric' is an isbn indexed multivalued field for finding books which is copied from 'isbn_tesim'
    #   <copyField source="isbn_tesim" dest="isbn_numeric"/>
    # the english text stored indexed multivalued field generated for the 'isbn' property a.k.a. object.isbn
    # See './app/models/monograph.rb' and './solr/config/schema.xml' for details.
    # Note: Since this happens server side see './solr/spec/core_spec.rb' for specs.

    context 'products' do
      let(:products) { [-1, 0, 1] }
      let(:product) { instance_double(Greensub::Product, 'product', name: 'Product') }

      before do
        allow(indexer).to receive(:all_product_ids_for_monograph).with(monograph).and_return(products)
        allow(Greensub::Product).to receive(:where).with(id: products).and_return([product])
      end

      it { expect(subject['products_lsim']).to be(products) }
      it { expect(subject[Solrizer.solr_name('product_names', :facetable)]).to contain_exactly('Open Access', 'Unrestricted', 'Product') }
    end
  end

  describe 'empty creator field' do
    subject { indexer.generate_solr_document }

    let(:indexer) { described_class.new(monograph) }
    let(:monograph) {
      build(:monograph,
            contributor: ["Moose, Bullwinkle\nSquirrel, Rocky"])
    }

    before do
      monograph.save!
    end

    it 'promotes the first contributor to creator' do
      expect(subject['creator_tesim']).to eq ['Moose, Bullwinkle']
      expect(subject['contributor_tesim']).to eq ['Squirrel, Rocky']
    end
  end

  describe '#all_product_ids_for_monograph' do
    subject { indexer.all_product_ids_for_monograph(monograph) }

    let(:indexer) { described_class.new(monograph) }
    let(:monograph) { create(:monograph) }

    it { is_expected.to contain_exactly(0) }

    context 'open access' do
      before { allow(monograph).to receive(:open_access).and_return('yes') }

      it { is_expected.to contain_exactly(-1, 0) }
    end

    context 'component' do
      let(:component) { instance_double(Greensub::Component, 'component', products: products) }
      let(:products) { [] }

      before do
        allow(Greensub::Component).to receive(:find_by).with(noid: monograph.id).and_return(component)
      end

      # Components without Products shouldn't exist really, but it's possible to have them
      # to we need to account for them.
      # A Component without a Product is not "nothing" or empty or [], which would leave it without
      # an Access Icon. Instead it's considered "0" or Unregistered.

      it { is_expected.to eq [0] }

      context 'open access' do
        before { allow(monograph).to receive(:open_access).and_return('yes') }

        # A component, with NO product, but that's still open access? I mean, I guess
        # it's both Open Access AND Unregistered. It's the same as below, where the
        # component DOES have a Product but is ALSO Open Access.

        it { is_expected.to contain_exactly(-1, 0) }
      end

      context 'product' do
        let(:products) { [product] }
        let(:product) { instance_double(Greensub::Product, 'product', id: 1) }

        it { is_expected.to contain_exactly(product.id) }

        context 'open access' do
          before { allow(monograph).to receive(:open_access).and_return('yes') }

          # The Component is both Open Access and belongs to a Product

          it { is_expected.to contain_exactly(-1, product.id) }
        end
      end

      context 'products' do
        let(:products) { [product1, product2] }
        let(:product1) { instance_double(Greensub::Product, 'product1', id: 1) }
        let(:product2) { instance_double(Greensub::Product, 'product2', id: 2) }

        it { is_expected.to contain_exactly(product1.id, product2.id) }

        context 'open access' do
          before { allow(monograph).to receive(:open_access).and_return('yes') }

          it { is_expected.to contain_exactly(-1, product1.id, product2.id) }
        end
      end
    end
  end
end
