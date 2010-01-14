module DevicesHelper
  
  # TODO: this is crude/wrong but works well enough for now
  def device_icon(mac)
    prefix = mac[0..4]
    iphone = ['00:23', '00:26', '00:25', '00:1B:63']
    iphone.include?(prefix) ? image_tag('/images/iphone.png') : image_tag('/images/laptop.png')
  end
end
