#!/bin/sh

# Запуск golangci-lint
echo "Running golangci-lint..."
golangci-lint run

# Проверка успешности выполнения линтера
if [ $? -ne 0 ]; then
  echo "golangci-lint failed. Aborting commit."
  exit 1
fi

echo "golangci-lint passed. Proceeding with commit."
