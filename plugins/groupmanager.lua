do

local function add_by_reply(extra, success, result)
    result = backward_msg_format(result)
    local msg = result
    local chat = msg.to.id
    local user = msg.from.id
    if msg.to.type == 'chat' then
        chat_add_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
    elseif msg.to.type == 'channel' then
        channel_invite_user('channel#id'..chat, 'user#id'..user, ok_cb, false)
    end
end
local function add_by_username(cb_extra, success, result)
    local chat_type = cb_extra.chat_type
    local chat_id = cb_extra.chat_id
    local user_id = result.peer_id
    local user_username = result.username
    print(chat_id)
    if chat_type == 'chat' then
        chat_add_user('chat#id'..chat_id, 'user#id'..user_id, ok_cb, false)
    elseif chat_type == 'channel' then
        channel_invite_user('channel#id'..chat_id, 'user#id'..user_id, ok_cb, false)
    end
end
local function kick_user(user_id, chat_id)
    local chat = 'chat#id'..chat_id
    local user = 'user#id'..user_id
    local channel = 'channel#id'..chat_id
    if user_id == tostring(our_id) then
        print("به نظرت میتونی خودتو کیک کنی؟!:|")
    else
        chat_del_user(chat, user, ok_cb, true)
        channel_kick_user(channel, user, ok_cb, true)
    end
end
local function chat_kick(extra, success, result)
    result = backward_msg_format(result)
    local msg = result
    local chat = msg.to.id
    local user = msg.from.id
    local chat_type = msg.to.type
    if chat_type == 'chat' then
        chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
    elseif chat_type == 'channel' then
        channel_kick_user('channel#id'..chat, 'user#id'..user, ok_cb, false)
    end
end
local function kick_by_username(cb_extra, success, result)
    chat_id = cb_extra.chat_id
    user_id = result.peer_id
    chat_type = cb_extra.chat_type
    user_username = result.username
    if chat_type == 'chat' then
        chat_del_user('chat#id'..chat_id, 'user#id'..user_id, ok_cb, false)
    elseif chat_type == 'channel' then
        channel_kick_user('channel#id'..chat_id, 'user#id'..user_id, ok_cb, false)
    end
end

local function run(msg, matches)
       if matches[1] == 'setname' or 'تنظیم اسم' then
        if permissions(msg.from.id, msg.to.id, "settings") then
            local hash = 'name:enabled:'..msg.to.id
            if not redis:get(hash) then
                if msg.to.type == 'chat' then
                    rename_chat(msg.to.peer_id, matches[2], ok_cb, false)
                elseif msg.to.type == 'channel' then
                    rename_channel(msg.to.peer_id, matches[2], ok_cb, false)
                end
            end
            return
        end
    elseif matches[1] == 'newlink' or 'لینک جدید' then
        if permissions(msg.from.id, msg.to.id, "setlink") then
        	local receiver = get_receiver(msg)
            local hash = 'link:'..msg.to.id
    		local function cb(extra, success, result)
    			if result then
    				redis:set(hash, result)
    			end
	            if success == 0 then
	                return send_large_msg(receiver, 'ارور! یا شما سازنده گروه نیستید یا هنوز لینک نساخته اید\nلینک جدید یا newlink\nرا بزنید!', ok_cb, true)
	            end
    		end
    		if msg.to.type == 'chat' then
                result = export_chat_link(receiver, cb, true)
            elseif msg.to.type == 'channel' then
                result = export_channel_link(receiver, cb, true)
            end
    		if result then
	            if msg.to.type == 'chat' then
	                send_msg('chat#id'..msg.to.id, 'New link created', ok_cb, true)
	            elseif msg.to.type == 'channel' then
	                send_msg('channel#id'..msg.to.id, 'New link created', ok_cb, true)
	            end
	        end
            return
        else
            return '?? '..lang_text(msg.to.id, 'require_admin')
        end
    elseif matches[1] == 'link' or 'لینک' then
        if permissions(msg.from.id, msg.to.id, "link") then
            hash = 'link:'..msg.to.id
            local linktext = redis:get(hash)
            if linktext then
                if msg.to.type == 'chat' then
                    send_msg('user#id'..msg.from.id, 'لینک برای گروه\n'..mag.to.title..'\n'..linktext, ok_cb, true)
                elseif msg.to.type == 'channel' then
                    send_msg('user#id'..msg.from.id, 'لینک برای سوپر گروه\n'..msg.to.title..'\n'..linktext, ok_cb, true)
                end
                return 'لینک به پیوی ارسال شد.'
            else
                if msg.to.type == 'chat' then
                    send_msg('chat#id'..msg.to.id, 'ارور!ابتدا لینک جدید بسازید\n!newlink یا لینک جدید.', ok_cb, true)
                elseif msg.to.type == 'channel' then
                    send_msg('channel#id'..msg.to.id, 'خطا!ابتدا لینک جدید برای سوپر گروه بسازید دستور:\nلینک جدید یا newlink', ok_cb, true)
                end
            end
            return
        end
    elseif matches[1] == 'tosuper' or 'تبدیل سوپر' then
        if msg.to.type == 'chat' then
            if permissions(msg.from.id, msg.to.id, "tosupergroup") then
                chat_upgrade('chat#id'..msg.to.id, ok_cb, false)
                return 'گروه |'..msg.to.title..'|به سوپر گروه تبدیل شد.'
            end
        else
            return 'خطا در ارتقا گروه\nدلیل:\nشما سازنده گروه نیستید!'
        end
            elseif matches[1] == 'kick' or 'اخراج' then
        if permissions(msg.from.id, msg.to.id, "kick") then
            local chat_id = msg.to.id
            local chat_type = msg.to.type
            if msg.reply_id then
                get_message(msg.reply_id, chat_kick, false)
                return
            end
            if not is_id(matches[2]) then
                local member = string.gsub(matches[2], '@', '')
                resolve_username(member, kick_by_username, {chat_id=chat_id, member=member, chat_type=chat_type})
                return
            else
                local user_id = matches[2]
                if msg.to.type == 'chat' then
                    chat_del_user('chat#id'..msg.to.id, 'user#id'..matches[2], ok_cb, false)
                elseif msg.to.type == 'channel' then
                    channel_kick_user('channel#id'..msg.to.id, 'user#id'..matches[2], ok_cb, false)
                    return "فرد نسبتا محترم از گروه شما اخراج شد."
                end
            end
        end
            elseif matches[1] == 'add' or 'ادد' then
        if permissions(msg.from.id, msg.to.id, "add") then
            local chat_id = msg.to.id
            local chat_type = msg.to.type
            if msg.reply_id then
                get_message(msg.reply_id, add_by_reply, false)
                return
            end
            if not is_id(matches[2]) then
                local member = string.gsub(matches[2], '@', '')
                print(chat_id)
                resolve_username(member, add_by_username, {chat_id=chat_id, member=member, chat_type=chat_type})
                return
            else
                local user_id = matches[2]
                if chat_type == 'chat' then
                    chat_add_user('chat#id'..chat_id, 'user#id'..user_id, ok_cb, false)
                elseif chat_type == 'channel' then
                    channel_invite_user('channel#id'..chat_id, 'user#id'..user_id, ok_cb, false)
              end
            end
    end
    elseif matches[1] == 'setdes' or 'تنظیم درباره' then
        if permissions(msg.from.id, msg.to.id, "description") then
            local text = matches[2]
            local chat = 'channel#id'..msg.to.id
            if msg.to.type == 'channel' then
                channel_set_about(chat, text, ok_cb, false)
                return 'با موفقیت تنظیم شد😉'
            end
        end
end
end
return {
    patterns = {
        '^[!/#](setname) (.*)$',
        '^(setname) (.*)$',
        '^(تنظیم اسم) (.*)$',
        '^[!/#](link)$',
        '^(link)$',
        '^(لینک)"',
        '^[!/#](newlink)$',
        '^(newlink)$',
        '^(لینک جدید)$',
        '^[!/#](tosuper)$',
        '^(tosuper)$',
        '^(تبدیل سوپر)$',
        '^[!/#](setdes) (.*)$',
        '^(setdes) (.*)$',
        '^(تنظیم درباره) (.*)$',
        "^[!/#](kick)$",
        "^(kick)$",
        "^(اخراج)$",
        "^[!/#](kick) (.*)$",
        "^(kick) (.*)$",
        "^(اخراج) (.*)$",
        "^[!/#](add)$",
        "^(add)$",
        "^(ادد)$",
        "^[!/#](add) (.*)$",
        "^(add) (.*)$",
        "^(ادد) (.*)$",
    },
    run = run
}
end
-- Create By Mr.Nitro
