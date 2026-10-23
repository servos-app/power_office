require_relative "test_helper"
require "socket"

class PowerOffice::ConnectionTest < Minitest::Test
  def test_wraps_the_http_response
    server = TCPServer.new("127.0.0.1", 0)
    responder = Thread.new do
      socket = server.accept
      socket.gets("\r\n\r\n")
      socket.write("HTTP/1.1 200 OK\r\nX-Pagination: {\"totalPages\":2}\r\nContent-Length: 2\r\n\r\n[]")
      socket.close
    end

    response = PowerOffice::Connection.perform(get(server))

    assert_equal 200, response.status
    assert_equal [], response.data
    assert_equal({"totalPages" => 2}, response.pagination)
  ensure
    responder&.kill
    server&.close
  end

  def test_a_refused_connection_raises_connection_error
    server = TCPServer.new("127.0.0.1", 0)
    request = get(server)
    server.close

    assert_raises(PowerOffice::Errors::ConnectionError) { PowerOffice::Connection.perform(request) }
  end

  # The listen backlog completes the handshake, but nothing ever answers.
  def test_a_timeout_raises_timeout_error
    server = TCPServer.new("127.0.0.1", 0)

    error = assert_raises(PowerOffice::Errors::TimeoutError) do
      PowerOffice::Connection.perform(get(server), timeout: 0.05)
    end
    assert_equal "Request timed out", error.message
  ensure
    server&.close
  end

  private

  def get(server)
    Net::HTTP::Get.new(URI("http://127.0.0.1:#{server.addr[1]}/v2/Customers"))
  end
end
