require "import"
import "android.widget.*"
import "android.view.*"
import "layout"
import "android.app.AlertDialog"
import "android.app.ProgressDialog"
import "cjson"
import "os"
import "math"
import "android.net.Uri"
import "android.content.*"



function exit()
  activity.finish()
end

function onService()
  Http.get("https://cdn.gkcoll.xyz/Celestial-Empire-LAN-Launcher/console.json", function(c,r)
    if c == 200 then
      data = cjson.decode(r)
      if data.Service.On then
        --pass
       else
        print(data.Service.CloseReason)
        exit()
      end
     else
      exit()
    end
  end)

end



function in_cn()
  Http.get("http://myip.ipip.net/", function(c,r)
    if c==200 then
      if string.find(r,"中国") then
        print("欢迎接入天朝局域网，点击『接入方式』可以进行下一步操作！")
       else
        print("您的 IP 不在中国境内，不允许连接天朝局域网！")
        exit()
      end
     else
      print("联网失败，禁止连接天朝局域网！")
      exit()
    end
  end)
end

function set_str()
  Http.get("https://cdn.gkcoll.xyz/Celestial-Empire-LAN-Launcher/message.json", function(c,r)
    if c == 200 then
      data=cjson.decode(r)
      notice.setText(data.notice)
      --math.randomseed(os.time())
      length=#data.sentence
      index = math.random(1, length)
      --print(length)
      --print(index)
      sentence.setText(data.sentence[index])
    end
  end)
end

function openinbr(url)
  viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
  activity.startActivity(viewIntent)
end

function open_app(packageName)
  if pcall(function() activity.getPackageManager().getPackageInfo(packageName,0) end) then
    manager = activity.getPackageManager()
    open = manager.getLaunchIntentForPackage(packageName)
    this.startActivity(open)
    return true
   else
    return false
  end
end

function get_param(engine, url)
  InputLayout={
    LinearLayout;
    orientation="vertical";
    Focusable=true,
    FocusableInTouchMode=true,
    {
      TextView;
      id="Prompt",
      textSize="15sp",
      layout_marginTop="10dp";
      layout_marginLeft="3dp",
      layout_width="80%w";
      layout_gravity="center",
      text="您选择了 "..engine.."路线，该路线支持带参数（一般是搜索关键词），请输入所需参数";
    };
    {
      EditText;
      hint="参数";
      layout_marginTop="5dp";
      layout_width="80%w";
      layout_gravity="center",
      id="edit";
    };
  };

  AlertDialog.Builder(this)
  .setTitle("参数获取器")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("确定",{onClick=function(v)
      openinbr(url..edit.Text)
  end})
  .setNegativeButton("取消",nil)
  .show()
  import "android.view.View$OnFocusChangeListener"
  edit.setOnFocusChangeListener(OnFocusChangeListener{
    onFocusChange=function(v,hasFocus)
      if hasFocus then
        Prompt.setTextColor(0xFD009688)
      end
  end})
end

function checkUpdate()
  --获取内部版本号和版本名
  local packinfo = this.getPackageManager().getPackageInfo(this.getPackageName(), 11*4+5*1*4)
  local versionName = tostring(packinfo.versionName)
  local versionCode = tonumber(packinfo.versionCode)

  --圆形旋转样式
  check_update_dialog = ProgressDialog(this)
  check_update_dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER)
  check_update_dialog.setTitle("提示")
  --设置进度条的形式为圆形转动的进度条
  check_update_dialog.setMessage("正在检查更新中，请稍等片刻……\n\n小提示，如果检查更新长时间无反应，按手机「返回键」可以取消检查更新")
  check_update_dialog.setCancelable(true)
  check_update_dialog.setCanceledOnTouchOutside(false)
  check_update_dialog.setOnCancelListener{
    onCancel=function(l)
      print("您取消了「检查更新」操作")
      return false
  end}
  check_update_dialog.show()

  Http.get("https://cdn.gkcoll.xyz/Celestial-Empire-LAN-Launcher/console.json",function(code,resp)
    data=cjson.decode(resp)
    check_update_dialog.hide()

    if versionCode < data.Update.BuildVersion then
      AlertDialog.Builder(this)
      .setTitle("新版本！")
      .setMessage("版本名：【"..data.Update.VersionName.."】（已安装【"..versionName.."】）".."\n发布时间："..data.Update.Time.."\n更新日志：\n"..data.Update.ChangeLog)
      .setPositiveButton("发布地址",function()
        openinbr(data.Update.Release)
        exit()
      end)
      .setNeutralButton("开源地址",function()
        openinbr(data.Update.OpenSource)
        exit()
      end)
      .setNegativeButton("取消",function()
        if data.Update.Force then
          print("此为重要的更新版本，开发者已设置强制更新，请进行更新！")
        end
      end)
      .show()
      if data.Update.Force then
        print("此为重要的更新版本，开发者已设置强制更新，请进行更新！")
        task(3000,function()
          openinbr(data.Update.Release)
          exit()
        end)
      end
     else
      set_str()
    end
  end)
end


in_cn()
onService()
checkUpdate()


activity.setContentView(loadlayout(layout))

star.onClick=function()
  AlertDialog.Builder(this)
  .setTitle("誓")
  .setMessage("待到城门重开日，\n必是我辈复出时！")
  .setPositiveButton("支持！",{
    onClick=function(v)
      print("谢谢！")
  end})
  .setNegativeButton("否定",nil)
  .show()
end

function access.onClick()
  items={"baidu", "sogou", "haoso", "fsou", "sm", "coolapk", "zhihu", "bilibili", "micromessage", "oicq", "weibo", "jianshu", "via", "lab"}
  AlertDialog.Builder(this)
  .setTitle("选择接入路线")
  .setItems(items,{onClick=function(l,v)

      if v==0 then
        param = get_param("百度", "https://www.baidu.com/s?wd=")
      end

      if v==1 then
        param = get_param("搜狗", "https://www.sogou.com/web?query=")
      end

      if v==2 then
        param = get_param("360 好搜", "https://www.so.com/s?q=")
      end

      if v==3 then
        param = get_param("F 搜", "https://fsoufsou.com/search?q=")
      end

      if v==4 then
        param = get_param("夸克神马", "https://quark.sm.cn/s?q=")
      end

      if v==5 then
        if open_app("com.coolapk.market") then
          print("检测到已安装酷安，即将自动打开..")
         else
          print("莫意思，你没有安装酷安，无法接入")
        end
      end

      if v==6 then
        if open_app("com.zhihu.android") then
          print("检测到已安装知乎，即将自动打开..")
         else
          param = get_param("知乎", "https://www.zhihu.com/search?q=")
        end
      end

      if v==7 then
        if open_app("tv.danmaku.bili") then
          print("检测到已安装哔哩哔哩，即将自动打开..")
         else
          param = get_param("B 站", "https://search.bilibili.com/all?keyword=")
        end
      end

      if v==8 then
        if open_app("com.tencent.mm") then
          pritn("检测到已安装微信，即将自动打开..")
         else
          print("莫意思，你没有安装微信，无法接入")
        end
      end

      if v==9 then
        if open_app("com.tencent.mobileqq") then
          print("检测到已安装 QQ，即将自动打开..")
         else
          if open_app("com.tencent.tim") then
            print("检测到已安装 TIM，即将自动打开..")
           else
            print("抱歉，您的手机没有装任何 QQ 应用，无法接入")
          end
        end
      end

      if v==10 then
        if open_app("com.sina.weibo") then
          print("检测到已安装微博，即将自动打开..")
         else
          if open_app("com.sina.weibolite") then
            print("检测到已安装微博极速版，即将自动打开..")
           else
            if open_app("com.weico.international") then
              print("检测到已安装微博轻享版，即将自动打开..")
             else
              param = get_param("微博", "https://s.weibo.com/weibo?q=")
            end
          end
        end
      end

      if v==11 then
        if open_app("com.jianshu.haruki") then
          print("检测到已安装简书，即将自动打开")
         else
          param = get_param("简书", "https://www.jianshu.com/search?q=")
        end
      end

      if v==12 then
        if open_app("mark.via") then
          print("检测到已安装 Via 浏览器，即将自动打开")
         else
          print("您没有安装 Via 浏览器，已自动打开系统浏览器")
          open_app("com.android.browser")
        end
      end

      if v == 13 then
        openinbr("https://lab.gkcoll.xyz")
      end
  end})
  .show()
end



function join.onClick()
  --824697580
  url="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=824697580&card_type=group&source=qrcode"
  activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
end

function blog.onClick()
  openinbr("https://www.gkcoll.xyz")
end

function about.onClick()
  Http.get("https://cdn.gkcoll.xyz/Celestial-Empire-LAN-Launcher/message.json", function(c,r)
    if c == 200 then
      data=cjson.decode(r)
      AlertDialog.Builder(this)
      .setTitle("关于")
      .setMessage(data.about)
      .setPositiveButton("了解",{onClick=function()end})
      .setNeutralButton("前往发布页",{onClick=function() openinbr("https://www.gkcoll.xyz/535.html") end})
      .show()
    end
  end)
end

function menu.onClick()
  pop=PopupMenu(activity, menu)
  m=pop.Menu
  m.add("联系作者").onMenuItemClick=function()
    activity.getSystemService(Context.CLIPBOARD_SERVICE).setText("gkcoll@111.com")
    print("已复制作者邮箱，请提供邮箱联系作者！")
  end
  m.add("开源仓库").onMenuItemClick=function()
    AlertDialog.Builder(this)
    .setTitle("开源仓库")
    .setMessage("开发不易，还请多多支持！快去帮忙点亮一下 star 吧！")
    .setPositiveButton("确定",{onClick=function()
        items={"GitHub", "GitCode", "Gitee"}
        AlertDialog.Builder(this)
        .setTitle("请选择开源仓库")
        .setItems(items,{onClick=function(l,v)

            if v==0 then
              openinbr("https://github.com/gkcoll/celestial-empire-lan-launcher")
            end
            if v==1 then
              openinbr("https://gitcode.net/weixin_46066592/celestial-empire-lan-launcher")
            end
            if v==2 then
              openinbr("https://gitee.com/gkcoll/celestial-empire-lan-launcher")
            end
        end})
        .show()
    end})
    .setNeutralButton("取消",{onClick=function() print("呜呜呜~你好坏！") end})
    .show()
  end
  m.add("退出程序").onMenuItemClick=function()
    exit()
  end
  pop.show()--显示
end
