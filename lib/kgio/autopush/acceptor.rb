# Copyright (C) 2015 all contributors <kgio-public@bogomips.org>
# License: LGPLv2.1 or later (https://www.gnu.org/licenses/lgpl-2.1.txt)

# using this code is not recommended, for backwards compatibility only
class Kgio::TCPServer
  include Kgio::Autopush

  alias_method :kgio_accept_orig, :kgio_accept
  undef_method :kgio_accept
  def kgio_accept(*args)
    kgio_autopush_post_accept(kgio_accept_orig(*args))
  end

  alias_method :kgio_tryaccept_orig, :kgio_tryaccept
  undef_method :kgio_tryaccept
  def kgio_tryaccept(*args)
    kgio_autopush_post_accept(kgio_tryaccept_orig(*args))
  end

private

  def kgio_autopush_post_accept(rv) # :nodoc:
    return rv unless Kgio.autopush? && rv.respond_to?(:kgio_autopush=)
    if my_state = FDMAP[fileno]
      if my_state.obj == self
        rv.kgio_autopush = true if my_state.ap_state == :acceptor
        return rv
      end
    else
      my_state = FDMAP[fileno] ||= Kgio::Autopush::APState.new
    end
    my_state.obj = self
    my_state.ap_state = nil
    begin
      n = getsockopt(Socket::IPPROTO_TCP, Kgio::Autopush::NOPUSH).unpack('i')
      my_state.ap_state = :acceptor if n[0] == 1
    rescue Errno::ENOTSUPP # non-TCP socket
    end
    rv.kgio_autopush = true if my_state.ap_state == :acceptor
    rv
  end
end
