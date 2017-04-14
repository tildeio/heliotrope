class RepositoryPresenter < ApplicationPresenter
  def publisher_ids
    Press.all.map(&:id)
  end

  def monograph_ids(publisher = nil)
    docs = ActiveFedora::SolrService.query("+has_model_ssim:Monograph", rows: 10_000)
    ids = []
    docs.each do |doc|
      if publisher.nil?
        ids << doc['id']
      elsif doc['press_tesim'].first == publisher.subdomain
        ids << doc['id']
      end
    end
    ids
  end

  def asset_ids(publisher = nil)
    asset_ids = []
    monograph_ids(publisher).each do |monograph_id|
      monograph_doc = ActiveFedora::SolrService.query("{!terms f=id}#{monograph_id}")
      unless monograph_doc.blank?
        asset_ids += monograph_doc[0][Solrizer.solr_name('ordered_member_ids', :symbol)] || []
      end
    end
    asset_ids
  end

  def user_ids(publisher = nil)
    return User.all.map(&:id) if publisher.nil?
    User.joins("INNER JOIN roles ON roles.user_id = users.id AND roles.resource_id = #{publisher.id} AND roles.resource_type = 'Press'").map(&:id)
  end
end