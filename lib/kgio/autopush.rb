# Copyright (C) 2015 all contributors <kgio-public@bogomips.org>
# License: LGPLv2.1 or later (https://www.gnu.org/licenses/lgpl-2.1.txt)

require 'socket'
require 'thread'

# using this code is not recommended, for backwards compatibility only
module Kgio::Autopush # :nodoc:
  class SyncArray # :nodoc:
    def initialize # :nodoc:
      @map = []
      @lock = Mutex.new
    end

    def []=(key, val) # :nodoc:
      @lock.synchronize { @map[key] = val }
    end

    def [](key) # :nodoc:
      @lock.synchronize { @map[key] }
    end
  end

  FDMAP = SyncArray.new # :nodoc:
  APState = Struct.new(:obj, :ap_state) # :nodoc:

  # Not using pre-defined socket constants for 1.8 compatibility
  if RUBY_PLATFORM.include?('linux')
    NOPUSH = 3 # :nodoc:
  elsif RUBY_PLATFORM.include?('freebsd')
    NOPUSH = 4 # :nodoc:
  end

  def kgio_autopush? # :nodoc:
    return false unless Kgio.autopush?
    state = FDMAP[fileno]
    state && state.obj == self && state.ap_state != :ignore
  end

  def kgio_autopush=(bool) # :nodoc:
    if bool
      state = FDMAP[fileno] ||= APState.new
      state.ap_state = :writer
      state.obj = self
    end
    bool
  end

private
  def kgio_push_pending # :nodoc:
    Kgio.autopush or return
    state = FDMAP[fileno] or return
    state.obj == self and state.ap_state = :written
  end

  def kgio_push_pending_data # :nodoc:
    Kgio.autopush or return
    state = FDMAP[fileno] or return
    state.obj == self && state.ap_state == :written or return
    setsockopt(Socket::IPPROTO_TCP, NOPUSH, 0)
    setsockopt(Socket::IPPROTO_TCP, NOPUSH, 1)
    state.ap_state = :writer
  end
end
require 'kgio/autopush/sock_rw'
require 'kgio/autopush/acceptor'
Kgio::TCPSocket.__send__(:include, Kgio::Autopush::SockRW) # :nodoc:
Kgio::Socket.__send__(:include, Kgio::Autopush::SockRW) # :nodoc:
