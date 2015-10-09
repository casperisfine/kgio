# Copyright (C) 2015 all contributors <kgio-public@bogomips.org>
# License: LGPLv2.1 or later (https://www.gnu.org/licenses/lgpl-2.1.txt)

# using this code is not recommended, for backwards compatibility only
module Kgio::Autopush::SockRW # :nodoc:
  include Kgio::Autopush

  def kgio_read(*) # :nodoc:
    kgio_push_pending_data
    super
  end

  def kgio_read!(*) # :nodoc:
    kgio_push_pending_data
    super
  end

  def kgio_tryread(*) # :nodoc:
    kgio_push_pending_data
    super
  end

  def kgio_trypeek(*) # :nodoc:
    kgio_push_pending_data
    super
  end

  def kgio_peek(*) # :nodoc:
    kgio_push_pending_data
    super
  end

  def kgio_syssend(*) # :nodoc:
    kgio_push_pending_data(super)
  end if Kgio::SocketMethods.method_defined?(:kgio_syssend)

  def kgio_trysend(*) # :nodoc:
    kgio_ap_wrap_writer(super)
  end

  def kgio_trywrite(*) # :nodoc:
    kgio_ap_wrap_writer(super)
  end

  def kgio_trywritev(*) # :nodoc:
    kgio_ap_wrap_writer(super)
  end

  def kgio_write(*) # :nodoc:
    kgio_ap_wrap_writer(super)
  end

  def kgio_writev(*) # :nodoc:
    kgio_ap_wrap_writer(super)
  end

private

  def kgio_ap_wrap_writer(rv) # :nodoc:
    case rv
    when :wait_readable, :wait_writable
      kgio_push_pending_data
    else
      kgio_push_pending
    end
    rv
  end
end
