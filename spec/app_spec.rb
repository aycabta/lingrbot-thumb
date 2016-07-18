# encoding: utf-8

ENV['RACK_ENV'] = 'test'

require_relative '../app'
require_relative './spec_helper'
require 'json'
require 'rack/test'

describe 'The Semantics=san' do
  include Rack::Test::Methods

  def app
    Bot
  end

  it 'web' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'ping' do
    post '/', create_message_json('ping')
    expect(last_response).to be_ok
    expect(last_response.body).to eq('pong')
  end

  it 'ping inside others' do
    post '/', create_message_json("わたし\nping\n大好きです")
    expect(last_response).to be_ok
    expect(last_response.body).to eq('')
  end

  it 'seiga' do
    post '/', create_message_json('http://seiga.nicovideo.jp/seiga/im5479269')
    expect(last_response).to be_ok
    expect(last_response.body).to eq('http://lohas.nicoseiga.jp/thumb/5479269i#.png')
  end

  it 'twitter' do
    post '/', create_message_json('https://twitter.com/kumikumitm/status/693000092534587392')
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Kumi TM (@kumikumitm) - 1RT / 5Fav 2016/01/29 18:17:52
#ggjsap @raa0121 働いておる https://t.co/Czqc94p4yg
https://pbs.twimg.com/media/CZ4H5jxWkAAHC6w.jpg
https://pbs.twimg.com/media/CZ4H6I5WcAAbBGo.jpg')
  end

  it 'pixiv' do
    post '/', create_message_json('http://www.pixiv.net/member_illust.php?mode=medium&illust_id=36540187')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("ワンワン霊体験 (by 押切蓮介)\nhttp://embed.pixiv.net/decorate.php?illust_id=36540187#.jpg")
  end

  it 'pixiv2' do
    post '/', create_message_json('http://www.pixiv.net/member_illust.php?illust_id=16125568&mode=medium')
    expect(last_response).to be_ok
    expect(last_response.body).to match(%r`ちだまりスティック \(by .*ジェ.*\)\nhttp://embed\.pixiv\.net/decorate\.php\?illust_id=16125568#\.jpg`)
  end

  it 'pixiv R-18' do
    post '/', create_message_json('http://www.pixiv.net/member_illust.php?mode=medium&illust_id=53233364')
    expect(last_response).to be_ok
    expect(last_response.body).to match(%r`^\[R-18\] Teaching Feeling ~奴隷との生活~ \(by Ray-Kbys\)\nhttp://.+\.pixiv\.net/c/64x64/img-\w+/img/.+\.jpg$`)
  end

  it 'pixiv R-18 ugoila' do
    post '/', create_message_json('http://www.pixiv.net/member_illust.php?mode=medium&illust_id=55721718')
    expect(last_response).to be_ok
    expect(last_response.body).to match(%r`^\[R-18\] 純愛ックス \(by Ray-Kbys\)\nhttp://.+\.pixiv\.net/c/64x64/img-\w+/img/.+\.jpg$`)
  end

  it 'pixiv R-18G' do
    post '/', create_message_json('http://www.pixiv.net/member_illust.php?mode=medium&illust_id=40455206')
    expect(last_response).to be_ok
    expect(last_response.body).to match('[R-18G] 夜道でばったり (by 田口綺麗)')
  end

  it 'nijie' do
    post '/', create_message_json('http://nijie.info/view.php?id=23460')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("（粘膜）密着！スペルマポリス２４ | ぶぶのすけ\nhttps://pic02.nijie.info/small_light(dw=70)/nijie_picture/2908_20120912222900.jpg")
  end

  it 'sp nijie' do
    post '/', create_message_json('http://sp.nijie.info/view.php?id=23460')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("（粘膜）密着！スペルマポリス２４ | ぶぶのすけ\nhttps://pic02.nijie.info/small_light(dw=70)/nijie_picture/2908_20120912222900.jpg")
  end

  it 'multi URL' do
    post '/', create_message_json('https://nijie.info/view.php?id=175400 https://twitter.com/kumikumitm/status/693000092534587392')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("白スク水らぁらちゃん。 | momoi
https://pic04.nijie.info/small_light(dw=70)/nijie_picture/578583_20160625122416_0.png
Kumi TM (@kumikumitm) - 1RT / 5Fav 2016/01/29 18:17:52
#ggjsap @raa0121 働いておる https://t.co/Czqc94p4yg
https://pbs.twimg.com/media/CZ4H5jxWkAAHC6w.jpg
https://pbs.twimg.com/media/CZ4H6I5WcAAbBGo.jpg")
  end

  it 'multi URL with multi line' do
    post '/', create_message_json('http://avex.jp/pripara/discography/detail.php?id=1010630
1
http://avex.jp/pripara/1st/discography/
2')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("プリパラ☆ミュージックコレクションDX／プリパラ☆ミュージックコレクション DVD/CD | TVアニメ「プリパラ」DVD・CD公式ホームページ
DVD/CD | TVアニメ「プリパラ」BD・DVD・CD公式ホームページ")
  end

  it '[]' do
    post '/', create_message_json('https://i.ytimg.com/vi/zADyHief9JE/maxresdefault.jpg?[1]=5')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("https://i.ytimg.com/vi/zADyHief9JE/maxresdefault.jpg?%5B1%5D=5")
  end

  it '[] with title' do
    post '/', create_message_json('https://www.youtube.com/watch?v=ZDJPDSawgE4&[99]=aa')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("https://www.youtube.com/watch?v=ZDJPDSawgE4&%5B99%5D=aa\nSansha sanyou Op full - YouTube")
  end

  it 'multibyte URL' do
    post '/', create_message_json('https://湘南台商店連合会.com/')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("https://xn--6oq16hen6c15e441ar5zrr0d.com/\n藤沢市北部の湘南台商店連合会公式サイト")
  end

  it 'multibyte URL' do
    post '/', create_message_json('https://湘南台商店連合会.com/news/日本の商店街では初めて？の日本語ドメイン利用/')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("https://xn--6oq16hen6c15e441ar5zrr0d.com/news/%E6%97%A5%E6%9C%AC%E3%81%AE%E5%95%86%E5%BA%97%E8%A1%97%E3%81%A7%E3%81%AF%E5%88%9D%E3%82%81%E3%81%A6%EF%BC%9F%E3%81%AE%E6%97%A5%E6%9C%AC%E8%AA%9E%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E5%88%A9%E7%94%A8/\n日本の商店街では初めて？の日本語ドメイン利用！ | 湘南台商店連合会公式サイト")
  end

  it 'multibyte URL' do
    post '/', create_message_json('https://ja.m.wikipedia.org/wiki/附属池田小事件')
    expect(last_response).to be_ok
    expect(last_response.body).to eq("https://ja.m.wikipedia.org/wiki/%E9%99%84%E5%B1%9E%E6%B1%A0%E7%94%B0%E5%B0%8F%E4%BA%8B%E4%BB%B6\n附属池田小事件 - Wikipedia")
  end
end
