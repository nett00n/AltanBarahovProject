#!/bin/bash
## Service vars
UtilityName="[$(basename $0)]"
ScriptPath=$(readlink -f $0)
ScriptDir=$(dirname $ScriptPath)
ParserWorkDir="$ScriptDir"

## User Variables

### Telegram bot info 
if [ -f ${ParserWorkDir}/.TGToken ];
    then
    TGToken=$(cat ${ParserWorkDir}/.TGToken)
else
    echo "Укажи Telegram Token своего бота, который будет отправлять сообщения"
    echo "Как зарегистрировать совего бота: https://core.telegram.org/bots#6-botfather"
    read TGToken
    echo $TGToken > ${ParserWorkDir}/.TGToken
fi

### Recepient info
if [ -f ${ParserWorkDir}/.TGChatID ];
    then
    TGChatID="$(cat ${ParserWorkDir}/.TGChatID)"
else
    echo "Укажи Telegram Chat ID пользователей, которым будут отправляться сообщения"
    echo "Можешь узнать свой Chat ID, написав этому боту: http://t.me/userinfobot"
    read TGChatID
    echo $TGChatID > ${ParserWorkDir}/.TGChatID
fi

### Usernames watch list:
if [ -f ${ParserWorkDir}/.DnevnikiYktUserNames ];
    then
    DnevnikiYktUserNames=$(cat ${ParserWorkDir}/.DnevnikiYktUserNames)
else
    echo "Укажи через пробел пользователей, за которыми ты хочешь следить"
    read DnevnikiYktUserNames
    echo $DnevnikiYktUserNames > ${ParserWorkDir}/.DnevnikiYktUserNames
fi

### Ensure data dir exists
if [ ! -d ${ParserWorkDir}/.data ];
        then
        mkdir ${ParserWorkDir}/.data
    fi

### Cycle for all usernames
for DnevnikiYktUserName in $DnevnikiYktUserNames;
do
    ### Check if dir for current user exists
    if [ ! -d ${ParserWorkDir}/.data/${DnevnikiYktUserName} ];
        then
        mkdir ${ParserWorkDir}/.data/${DnevnikiYktUserName}
    fi

    ### Check if feed is new
    if [ -f ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentPostList ]
        then
        CurrentFeedIsSilent="false"
        else
        CurrentFeedIsSilent="true"
    fi

    ### Get Raw data. With magic
    curl -s http://dnevniki.ykt.ru/${DnevnikiYktUserName} | grep -s 'class="post-item__title-link"' -A 1 | sed 's/<a href="//g' | sed 's/\" class=\"post-item__title-link\">//g' > ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentParseResult

    ### Parse every post URL:
    cat ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentParseResult | grep http | awk -F '/' '{print $(NF)}' > ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentPostList

    for CurrentPost in $(cat ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentPostList);
    do
    ### Cycle finding new posts
    if [ ! -f ${ParserWorkDir}/.data/${DnevnikiYktUserName}/${CurrentPost}.head ];
            then
            cat ${ParserWorkDir}/.data/${DnevnikiYktUserName}/.CurrentParseResult | grep $CurrentPost -A 1 > ${ParserWorkDir}/.data/${DnevnikiYktUserName}/${CurrentPost}.head
            if [ $CurrentFeedIsSilent = "true" ]
                then
                for CurrentRecipient in $TGChatID;
                    do
                        curl -s -X POST https://api.telegram.org/bot$TGToken/sendMessage -d chat_id=$TGChatID -d text="Алтан говорит, что тут новый пост: $(cat ${ParserWorkDir}/.data/${DnevnikiYktUserName}/${CurrentPost}.head)"
                    done
                fi
            fi
    done
    if [ $CurrentFeedIsSilent = "true" ]
        then
            curl -s -X POST https://api.telegram.org/bot$TGToken/sendMessage -d chat_id=$TGChatID -d text="Алтан говорит, что лента ${DnevnikiYktUserName} успешно добавилась в список отслеживаемого"
    fi
done