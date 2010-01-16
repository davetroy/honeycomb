require 'test_helper'

class InvoiceMailerTest < ActionMailer::TestCase
  test "invoice" do
    @expected.subject = 'InvoiceMailer#invoice'
    @expected.body    = read_fixture('invoice')
    @expected.date    = Time.now

    assert_equal @expected.encoded, InvoiceMailer.create_invoice(@expected.date).encoded
  end

end
