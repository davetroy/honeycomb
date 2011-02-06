require 'test_helper'

class InvoiceMailerTest < ActionMailer::TestCase
  test "invoice" do
    @expected.subject = 'InvoiceMailer#invoice'
    @expected.body    = read_fixture('invoice')
    @expected.date    = Time.now

    # TODO fix this test to actaully test the invoice
    # assert_equal @expected.encoded, InvoiceMailer.create_invoice(@expected.date).encoded
  end

end
