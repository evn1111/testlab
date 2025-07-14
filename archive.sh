#!/bin/bash

# Скрипт для архивирования .conf файлов из /etc
# Использование: ./backup_conf.sh /path/to/backup/directory

# Проверка количества аргументов
if [ $# -ne 1 ]; then
    echo "Использование: $0 <директория_для_архивов>"
    echo "Пример: $0 /home/user/backups"
    exit 1
fi

BACKUP_DIR="$1"

# Проверка существования директории
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Создание директории $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
fi

# Получение текущей даты для имени архива
DATE=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="etc_conf_backup_${DATE}.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"

echo "Создание архива: $ARCHIVE_PATH"

# Создание архива с .conf файлами из /etc
tar -czf "$ARCHIVE_PATH" -C /etc $(find /etc -maxdepth 1 -name "*.conf" -printf "%f ")

if [ $? -eq 0 ]; then
    echo "Архив успешно создан: $ARCHIVE_PATH"
    
    # Подсчет количества архивов в директории
    ARCHIVE_COUNT=$(find "$BACKUP_DIR" -name "etc_conf_backup_*.tar.gz" | wc -l)
    echo "Всего архивов в директории: $ARCHIVE_COUNT"
    
    # Удаление старых архивов, если их больше 5
    if [ $ARCHIVE_COUNT -gt 5 ]; then
        echo "Найдено более 5 архивов. Удаление самого старого..."
        OLDEST_ARCHIVE=$(find "$BACKUP_DIR" -name "etc_conf_backup_*.tar.gz" -printf "%T@ %p\n" | sort -n | head -1 | cut -d' ' -f2-)
        rm "$OLDEST_ARCHIVE"
        echo "Удален старый архив: $OLDEST_ARCHIVE"
    fi
else
    echo "Ошибка при создании архива"
    exit 1
fi

echo "Операция завершена успешно" 