////////////////////////////////////////////////
// -- Create by ilaixDev
// -- Power by https://claude.ai/
// -- ไม่อนุญาติให้นำไปขาย
// -- สามารถนำไปทำเพิ่มแก้บัคต่างๆได้เอง
// -- ลิ้ง TWITTER_URL เปลื่ยนเป้นของตัวเองได้เลย
// -- อย่าลืมแก้ Database ตรงบรรทัด47
////////////////////////////////////////////////

#include <YSI_Coding\y_hooks>

#define TWITTER_URL "https://wargang-2-0.vercel.app/niranam_twitter/index.html" 
#define CEF_INTERFACE_ID 1

#define DATA_DELIM '\x01'

new MySQL:dbHandle;
static bool:IsPhoneOpen[MAX_PLAYERS];
static bool:IsBrowserReady[MAX_PLAYERS];
static PlayerNickname[MAX_PLAYERS][50];
static PlayerAvatar[MAX_PLAYERS][256];
static PlayerBio[MAX_PLAYERS][150];

static TempMsg[MAX_PLAYERS][900];
static TempImg[MAX_PLAYERS][512];

forward TogglePlayerPhone(playerid);
forward OnRequestClosePhone(playerid);
forward OnPlayerTweet(playerid, const data[]);
forward OnTweetInserted(playerid);
forward OnPlayerSaveSettings(playerid, const data[]);
forward OnLoadTweets(playerid);
forward OnLoadProfile(playerid);
forward OnBrowserReady(playerid);
forward OnTweetAction(playerid, const data[]);
forward OnRequestProfile(playerid, const username[]);
forward OnSendProfileData(playerid, const username[]);

stock FindDelimFrom(const data[], start_pos, dataLen) {
    for(new i = start_pos; i < dataLen; i++) {
        if(data[i] == DATA_DELIM) return i;
    }
    return -1;
}

hook OnGameModeInit() {
    dbHandle = mysql_connect("127.0.0.1", "root", "", "vectorx_db");
    
    if(mysql_errno(dbHandle) != 0) print("[Twitter]: MySQL Connection Failed!");
    else {
        print("[Twitter]: MySQL Connected!");
        
        mysql_query(dbHandle, "SET NAMES utf8mb4");
        mysql_query(dbHandle, "SET CHARACTER SET utf8mb4");
        
        mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `twitter_profiles` (\
            `username` varchar(50) NOT NULL, \
            `nickname` varchar(50) DEFAULT NULL, \
            `avatar_url` text DEFAULT NULL, \
            `bio` varchar(150) DEFAULT '', \
            PRIMARY KEY (`username`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `tweets` (\
            `id` int(11) NOT NULL AUTO_INCREMENT, \
            `username` varchar(50) NOT NULL, \
            `skin_id` int(11) DEFAULT 0, \
            `message` text NOT NULL, \
            `image_url` text DEFAULT NULL, \
            `avatar_url` text DEFAULT NULL, \
            `likes` int(11) DEFAULT 0, \
            `retweets` int(11) DEFAULT 0, \
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP, \
            PRIMARY KEY (`id`), \
            KEY `idx_id_desc` (`id` DESC)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        mysql_tquery(dbHandle, "ALTER TABLE `twitter_profiles` ADD `bio` varchar(150) DEFAULT ''", "", "");
        mysql_tquery(dbHandle, "ALTER TABLE `tweets` ADD `likes` int(11) DEFAULT 0, ADD `retweets` int(11) DEFAULT 0", "", "");
    }

    cef_subscribe("requestClosePhone", "OnRequestClosePhone");
    cef_subscribe("onPlayerTweet", "OnPlayerTweet");
    cef_subscribe("onPlayerSaveSettings", "OnPlayerSaveSettings");
    cef_subscribe("browserReady", "OnBrowserReady");
    cef_subscribe("onTweetAction", "OnTweetAction");
    cef_subscribe("requestProfile", "OnRequestProfile");
    return 1;
}

hook OnPlayerConnect(playerid) {
    IsPhoneOpen[playerid] = false;
    IsBrowserReady[playerid] = false;
    PlayerAvatar[playerid][0] = '\0';
    PlayerNickname[playerid][0] = '\0';
    PlayerBio[playerid][0] = '\0';
    
    GetPlayerName(playerid, PlayerNickname[playerid], 50);
    
    new name[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, name, sizeof(name));
    
    mysql_format(dbHandle, query, sizeof(query), 
        "SELECT `nickname`, `avatar_url`, `bio` FROM `twitter_profiles` WHERE `username` = '%e' LIMIT 1", name);
    mysql_tquery(dbHandle, query, "OnLoadProfile", "i", playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    IsPhoneOpen[playerid] = false;
    IsBrowserReady[playerid] = false;
    cef_destroy_browser(playerid, CEF_INTERFACE_ID);
    return 1;
}

public OnBrowserReady(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    if(IsBrowserReady[playerid]) return 1;

    IsBrowserReady[playerid] = true;
    printf("[Twitter]: JS พร้อมแล้ว player %d", playerid);

    cef_emit_event(playerid, "setPlayerData", 
        CEFSTR(PlayerNickname[playerid]), 
        CEFINT(GetPlayerSkin(playerid)),
        CEFSTR(PlayerAvatar[playerid]),
        CEFSTR(PlayerBio[playerid])
    );

    mysql_tquery(dbHandle, 
        "SELECT `id`, `username`, `skin_id`, `message`, `image_url`, `avatar_url`, UNIX_TIMESTAMP(`created_at`) as `ts`, `likes`, `retweets` FROM `tweets` ORDER BY `id` DESC LIMIT 20", 
        "OnLoadTweets", "i", playerid);
    return 1;
}

public TogglePlayerPhone(playerid) {
    if(!IsBrowserReady[playerid]) {
        SendClientMessage(playerid, 0xFF4400FF, "[Twitter]: กรุณารอสักครู่ กำลังโหลด...");
        return 1;
    }
    
    if(!IsPhoneOpen[playerid]) {
        cef_focus_browser(playerid, CEF_INTERFACE_ID, true);
        cef_emit_event(playerid, "togglePhone", CEFINT(1)); 
        IsPhoneOpen[playerid] = true;
    } else {
        cef_emit_event(playerid, "togglePhone", CEFINT(0)); 
        cef_focus_browser(playerid, CEF_INTERFACE_ID, false);
        IsPhoneOpen[playerid] = false;
    }
    return 1;
}

public OnTweetAction(playerid, const data[]) {
    new idStr[20], typeStr[10], stateStr[5];
    new len = strlen(data);
    new delim1 = FindDelimFrom(data, 0, len);
    new delim2 = -1;
    
    if(delim1 != -1) delim2 = FindDelimFrom(data, delim1 + 1, len);
    
    if(delim1 != -1 && delim2 != -1) {
        strmid(idStr, data, 0, delim1, 20);
        strmid(typeStr, data, delim1 + 1, delim2, 10);
        strmid(stateStr, data, delim2 + 1, len, 5);
        
        new tweetId = strval(idStr);
        new actionState = strval(stateStr);
        new query[128];
        
        if(!strcmp(typeStr, "like", true)) {
            if(actionState == 1) format(query, sizeof(query), "UPDATE tweets SET likes = likes + 1 WHERE id = %d", tweetId);
            else format(query, sizeof(query), "UPDATE tweets SET likes = likes - 1 WHERE id = %d", tweetId);
        } else if(!strcmp(typeStr, "rt", true)) {
            if(actionState == 1) format(query, sizeof(query), "UPDATE tweets SET retweets = retweets + 1 WHERE id = %d", tweetId);
            else format(query, sizeof(query), "UPDATE tweets SET retweets = retweets - 1 WHERE id = %d", tweetId);
        }
        if(strlen(query) > 0) mysql_tquery(dbHandle, query);
    }
    return 1;
}

public OnRequestProfile(playerid, const username[]) {
    new query[256];
    mysql_format(dbHandle, query, sizeof(query), "SELECT nickname, avatar_url, bio FROM twitter_profiles WHERE nickname = '%e' LIMIT 1", username);
    mysql_tquery(dbHandle, query, "OnSendProfileData", "is", playerid, username);
    return 1;
}

public OnSendProfileData(playerid, const username[]) {
    if(cache_num_rows() > 0) {
        new nick[50], ava[256], bio[150];
        cache_get_value_name(0, "nickname", nick, 50);
        cache_get_value_name(0, "avatar_url", ava, 256);
        cache_get_value_name(0, "bio", bio, 150);
        cef_emit_event(playerid, "showProfileData", CEFSTR(nick), CEFSTR(ava), CEFSTR(bio));
    }
    return 1;
}

public OnPlayerTweet(playerid, const data[]) {
    new msg[900], img[512]; 
    new dataLen = strlen(data);
    new delimPos = FindDelimFrom(data, 0, dataLen);

    if(delimPos == -1) {
        new copyLen = (dataLen < 899) ? dataLen : 899;
        strmid(msg, data, 0, copyLen, 900);
        img[0] = '\0';
    } else {
        new msgLen = (delimPos < 899) ? delimPos : 899;
        strmid(msg, data, 0, msgLen, 900);
        new imgStart = delimPos + 1;
        new imgLen   = dataLen - imgStart;
        new imgCopy  = (imgLen < 511) ? imgLen : 511;
        strmid(img, data, imgStart, imgStart + imgCopy, 512);
    }

    if(strlen(msg) < 1) return 1;

    format(TempMsg[playerid], 900, "%s", msg);
    format(TempImg[playerid], 512, "%s", img);

    new query[2048];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `tweets` (`username`, `skin_id`, `message`, `image_url`, `avatar_url`) VALUES ('%e', %d, '%e', '%e', '%e')",
        PlayerNickname[playerid], GetPlayerSkin(playerid), msg, img, PlayerAvatar[playerid]);
    mysql_tquery(dbHandle, query, "OnTweetInserted", "i", playerid);
    return 1;
}

public OnTweetInserted(playerid) {
    new insert_id = cache_insert_id();
    new ts = gettime();
    
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(!IsPlayerConnected(i) || !IsBrowserReady[i]) continue;
        
        cef_emit_event(i, "pushTweet",
            CEFINT(insert_id),
            CEFSTR(PlayerNickname[playerid]),
            CEFINT(GetPlayerSkin(playerid)),
            CEFSTR(TempMsg[playerid]),
            CEFSTR(TempImg[playerid]),
            CEFSTR(PlayerAvatar[playerid]),
            CEFINT(ts),
            CEFINT(0),
            CEFINT(0)
        );
    }
    return 1;
}

public OnLoadProfile(playerid) {
    if(cache_num_rows() > 0) {
        cache_get_value_name(0, "nickname", PlayerNickname[playerid], 50);
        cache_get_value_name(0, "avatar_url", PlayerAvatar[playerid], 256);
        cache_get_value_name(0, "bio", PlayerBio[playerid], 150);
    }
    
    if(IsBrowserReady[playerid]) {
        cef_emit_event(playerid, "setPlayerData", 
            CEFSTR(PlayerNickname[playerid]), 
            CEFINT(GetPlayerSkin(playerid)),
            CEFSTR(PlayerAvatar[playerid]),
            CEFSTR(PlayerBio[playerid])
        );
    }
    return 1;
}

public OnLoadTweets(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    new rows = cache_num_rows();
    if(rows > 0) {
        for(new i = rows - 1; i >= 0; i--) {
            new nick[50], msg[256], img[256], ava[256], skin, id, ts, likes, rts;
            cache_get_value_name_int(i, "id", id);
            cache_get_value_name(i, "username", nick, 50);
            cache_get_value_name(i, "message", msg, 256);
            cache_get_value_name(i, "image_url", img, 256);
            cache_get_value_name(i, "avatar_url", ava, 256);
            cache_get_value_name_int(i, "skin_id", skin);
            cache_get_value_name_int(i, "ts", ts);
            cache_get_value_name_int(i, "likes", likes);
            cache_get_value_name_int(i, "retweets", rts);
            cef_emit_event(playerid, "loadTweet", CEFINT(id), CEFSTR(nick), CEFINT(skin), CEFSTR(msg), CEFSTR(img), CEFSTR(ava), CEFINT(ts), CEFINT(likes), CEFINT(rts));
        }
    }
    cef_emit_event(playerid, "tweetsLoaded");
    return 1;
}

public OnPlayerSaveSettings(playerid, const data[]) {
    new nickname[150], avatar_url[256], bio[150];
    new dataLen = strlen(data);

    new delim1 = FindDelimFrom(data, 0, dataLen);
    new delim2 = -1;
    if(delim1 != -1) delim2 = FindDelimFrom(data, delim1 + 1, dataLen);

    if(delim1 == -1) {
        new copyLen = (dataLen < 149) ? dataLen : 149;
        strmid(nickname, data, 0, copyLen, 150);
        avatar_url[0] = '\0';
        bio[0] = '\0';
    } else if(delim2 == -1) {
        strmid(nickname, data, 0, delim1, 150);
        new avaLen = dataLen - (delim1 + 1);
        new avaCopy = (avaLen < 255) ? avaLen : 255;
        strmid(avatar_url, data, delim1 + 1, delim1 + 1 + avaCopy, 256);
        bio[0] = '\0';
    } else {
        strmid(nickname, data, 0, delim1, 150);
        new avaLen = delim2 - (delim1 + 1);
        new avaCopy = (avaLen < 255) ? avaLen : 255;
        strmid(avatar_url, data, delim1 + 1, delim1 + 1 + avaCopy, 256);
        
        new bioStart = delim2 + 1;
        new bioLen = dataLen - bioStart;
        new bioCopy = (bioLen < 149) ? bioLen : 149;
        strmid(bio, data, bioStart, bioStart + bioCopy, 150);
    }

    if(strlen(nickname) < 1) return 1;

    new realName[MAX_PLAYER_NAME], query[1024];
    GetPlayerName(playerid, realName, sizeof(realName));

    format(PlayerNickname[playerid], 50, "%s", nickname);
    format(PlayerAvatar[playerid], 256, "%s", avatar_url);
    format(PlayerBio[playerid], 150, "%s", bio);

    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `twitter_profiles` (`username`, `nickname`, `avatar_url`, `bio`) VALUES ('%e', '%e', '%e', '%e') \
        ON DUPLICATE KEY UPDATE `nickname` = VALUES(`nickname`), `avatar_url` = VALUES(`avatar_url`), `bio` = VALUES(`bio`)",
        realName, nickname, avatar_url, bio);
    mysql_tquery(dbHandle, query);

    cef_emit_event(playerid, "setPlayerData",
        CEFSTR(PlayerNickname[playerid]),
        CEFINT(GetPlayerSkin(playerid)),
        CEFSTR(PlayerAvatar[playerid]),
        CEFSTR(PlayerBio[playerid])
    );

    SendClientMessage(playerid, 0x1D9BF0FF, "[Twitter]: บันทึกโปรไฟล์เรียบร้อย!");
    return 1;
}

public OnRequestClosePhone(playerid) return TogglePlayerPhone(playerid);

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/p", true)) {
        TogglePlayerPhone(playerid);
        return 1;
    }
    return 0;
}

hook OnCefInitialize(playerid, success) {
    if(success) {
        cef_create_browser(playerid, CEF_INTERFACE_ID, TWITTER_URL, false, false);
    }
    return 1;
}
