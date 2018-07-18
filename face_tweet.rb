#Twitter APIで自動投稿
require 'twitter'
require 'open-uri'
require 'opencv'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end



#-----------------------------------------------------------
#tweetフェーズ
#ローカルフォルダ『a』の中の画像を10秒毎に自動投稿
Dir.foreach('a') do |f|
  next if f == '.' or f == '..' or f == '.DS_Store'
  image = OpenCV::IplImage::load("./a/#{f}")
  #haarcascade_frontalface_default.xmという顔認識用のファイルを取得し、フォルダ内に入れておく
  haar_xml_file = File.expand_path File.dirname(__FILE__), 'haarcascade_frontalface_default.xml'
  detector = OpenCV::CvHaarClassifierCascade::load(haar_xml_file)

  detector.detect_objects(image).each do |rect|
    # puts "detect!! : #{rect.top_left}, #{rect.top_right}, #{rect.bottom_left}, #{rect.bottom_right}"
    #f(hoge.jpg)を開いてtmpファイルにして投稿
          open("a/#{f}") do |tmp|
            client.update_with_media("test", tmp)
          end
          puts "done"
          sleep(10)
          File.delete("./a/#{f}")#顔認識された画像を削除
          break#これがなければ顔が検出された人数分だけ投稿してしまう。最初の一人が発見された時点で投稿し、break
  end
  File.delete("./a/#{f}")#顔認識されなかった画像を削除
end
