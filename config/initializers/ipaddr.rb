class IPAddr
  def prefix
    m = case @family
        when Socket::AF_INET
          IN4MASK
        when Socket::AF_INET6
          IN6MASK
        else
          raise 'unsupported address family'
        end
    $1.length if /\A(1*)(0*)\z/ =~ (@mask_addr & m).to_s(2)
  end

  def to_pretty
    case @family
    when Socket::AF_INET
      "#{to_s}/#{prefix}"
    else
      to_s
    end
  end
end
