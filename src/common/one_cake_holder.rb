module OneCakeHolder
  def verify_doesnt_have_a_cake_already
    @plate && one_cake_message.play && return
    true
  end

  private
  def one_cake_message
    @@message ||= Gosu::Sample.new(@shop_window.window, res('media/cant_put_two_cakes_in_there.ogg'))
  end
end
