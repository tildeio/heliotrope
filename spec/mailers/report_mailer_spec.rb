
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportMailer, type: :mailer do
  describe '#send_report' do
    let(:press) { create(:press, subdomain: "blue", name: "The Blue Press") }
    let(:press_admin) { create(:press_admin, press: press) }
    let(:report_heading) { "This is the report heading for #{press.name}" }
    let(:report_name) { "Total_Item_Requests" }
    let(:csv) do
      <<-CSV
#{report_heading},"",""
"",Jan-2018,Feb-2018
One Institution,1,0
Two Institution,1,1
      CSV
    end
    let(:csv_file) do
      tmp = Tempfile.new
      tmp.write(csv)
      tmp.close
      tmp
    end
    let(:start_date) { Date.parse("2018-01-01") }
    let(:end_date) { Date.parse("2018-02-28") }

    let(:mail) { described_class.send_report({ email: press_admin.email,
                                               report_heading: report_heading,
                                               csv_file: csv_file,
                                               report_name: report_name,
                                               press: press.name,
                                               start_date: start_date,
                                               end_date: end_date
                                             }).deliver }

    it 'has the correct fields and attachment' do
      expect(mail.from).to eq ["fulcrum-info@umich.edu"]
      expect(mail.to).to eq [press_admin.email]
      expect(mail.subject).to eq(report_heading)
      expect(mail.body.encoded).to match("Attached is a COUNTER 5 based Institution Usage report generated by Fulcrum, with the following parameters:")
      expect(mail.body.encoded).to match("Collection: #{press.name}")
      expect(mail.body.encoded).to match("Usage type: #{report_name}")
      expect(mail.body.encoded).to match("Date range: #{start_date} through #{end_date}")
      expect(mail.attachments[0].filename).to eq "This_is_the_report_heading_for_The_Blue_Press.csv"
    end
  end
end
