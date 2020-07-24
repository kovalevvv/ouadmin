# ИНСТРУКЦИЯ


* Задать конфигурацию в docker-compose.yml
* Задать корретный volume в docker-compose.yml
* Заменить ouadmin.key и ouadmin.crt
* docker-compose build ...

- **SMTP_**: Конфигурация smtp
- **SELF_HOST**: Домен, на котором будет это все работать. Необходимо для формирования ссылок в почтовых уведомлениях
- **SELF_PORT**: Порт. Должен быть 443, в любом случае только ssl
- **OUADMIN_HOST**: Хост контроллера домена
- **OUADMIN_PORT**: Порт.
- **OUADMIN_ENCRYPTION**: Шифрование (Булев)

- **OUADMIN_ACCOUNT**: Учетка с правами создания пользователей в OU
- **OUADMIN_ACCOUNT_PASSWORD**: Пароль

- **OUADMIN_GLOBAL_SEARCH_DN**: DN глобального каталога. Для пооиска пользователей, проверки логинов.
- **OUADMIN_GLOBAL_SEARCH_PORT**: Порт глобального каталога на котроллере домена

- **OUADMIN_OU_DN**: OU где создавать пользователей 
- **OUADMIN_ADMIN_GROUP**: DN группы с доступом в dashboard