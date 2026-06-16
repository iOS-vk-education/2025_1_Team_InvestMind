# Инструкция по настройке Firebase

## Добавление Firebase SDK через Xcode

1. Откройте проект `InvestMind.xcodeproj` в Xcode
2. В навигаторе проекта выберите проект (самый верхний элемент)
3. Выберите таргет `InvestMind`
4. Перейдите на вкладку **Package Dependencies**
5. Нажмите кнопку **+** (Add Package Dependency)
6. Введите URL: `https://github.com/firebase/firebase-ios-sdk`
7. Нажмите **Add Package**
8. Выберите следующие продукты:
   - **FirebaseAuth**
   - **FirebaseCore**
9. Нажмите **Add Package**

## Настройка Firebase Authentication в консоли

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите проект `investmind-28ffe`
3. Перейдите в **Authentication** > **Sign-in method**
4. Включите следующие методы входа:
   - **Email/Password** (для авторизации по телефону с паролем)
   - **Phone** (опционально, для SMS верификации)
   - **Apple** (если планируете использовать Sign in with Apple)
   - **VK** (если планируете использовать VK авторизацию)

## Проверка GoogleService-Info.plist

Убедитесь, что файл `GoogleService-Info.plist` находится в папке `InvestMind` и добавлен в таргет проекта.

## Готово!

После выполнения этих шагов авторизация через Firebase будет работать.

