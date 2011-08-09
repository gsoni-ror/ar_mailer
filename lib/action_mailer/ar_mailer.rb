##
# Adds sending email through an ActiveRecord table as a delivery method for
# ActionMailer.
#

class ActionMailer::Base

  ##
  # Set the email class for deliveries. Handle class reloading issues which prevents caching the email class.
  #
  @@email_class_name = 'Email'

  def self.email_class=(klass)
    @@email_class_name = klass.to_s
  end

  def self.email_class
    @@email_class_name.constantize
  end

  ##
  # Adds +mail+ to the Email table.  Only the first From address for +mail+ is
  # used.

  def perform_delivery_activerecord(mail)
    require "action_mailer/ar_sendmail"
    destinations = mail.destinations
    mail.ready_to_send
    sender = (mail['return-path'] && mail['return-path'].spec) || mail.from.first
    destinations.each do |destination|
      m = self.class.email_class.create :mail => mail.encoded, :to => destination, :from => sender, :priority => (@priority.present? ? @priority : 3)
      if m.priority==-1
        sendmail = ActionMailer::ARSendmail.new
        sendmail.deliver([m])
        m.destroy
      end
    end
  end

end
