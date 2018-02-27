# Altan Barahov Project

## Простой скрипт на bash для парсинга новых постов на площадке http://dnevniki.ykt.ru и нотификации о них с использованием личного телеграм-бота
Предполагает только одного получателя сообщений. Если необходимо - 

## Установка
* Выберем папку, куда проводится инсталляция: `cd ~/`
* Клонируем репозиторий: `git clone https://github.com/nett00n/AltanBarahovProject.git` либо переносим скрипт на сервер любым другим удобным вам способом
* Даём права на исполнение, если их нет: `chmod +x ~/AltanBarahovProject`
* Запускаем скрипт первый раз, указывая, кому отправлять сообщения, каким ботом, и за какими пользователями мы хотим следить. Обратите внимание, что при первом запуске бот отправит вам список из 20 последних постов каждого пользователя!
* Добавляем в планировщик заданий исполнение нашего скрипта: `crontab -e`
* Такая строка будет исполнять скрипт в 10:00 каждого дня: `00 10 * * * ~/AltanBarahovProject/dnevniki.ykt.ru.parser.sh`

## Последующая настройка
Конфигурация хранится в файлах рабочей директории:
* `.TGToken` - токен бота в телеграм;
* `.TGChatID` - получатель сообщений
* `.DnevnikiYktUserNames` - список пользователей, за которыми мы следим

## Особенности работы
При работе скрипта не используются базы данных, данные складываются в паку `.data` в подпапку имени пользователя.
Там создаются файлы `*.head` со ссылкой и заголовком поста и файлы `.CurrentParseResult`, `.CurrentPostList` - для  отладки
Парсится только первая страница с постами, так если сначала распарсилось 20 постов, а потом пользователь удалил один из них - может прийти оповещение о более старых постах
Постарался продумать структуру данных так, чтоб скрипт можно было обновлять, но ничего не гарантирую.

## Почему Алтан Барахов?
Прост)) (c)
случайные якутские имя и фамилия, никакого заговора.

## ToDo:
[] добавить Debug Mode
[] добавить опцию тихого заполнения БД, для новых фидов