# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-BusPaulo
CONFIG += sailfishapp
CONFIG += C++11

QT += gui positioning location sql core

SOURCES += \
    src/harbour-BusPaulo.cpp \
    src/managedb.cpp

OTHER_FILES += \
    qml/harbour-BusPaulo.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-BusPaulo.changes.in \
    rpm/harbour-BusPaulo.spec \
    rpm/harbour-BusPaulo.yaml \
    translations/*.ts \
    harbour-BusPaulo.desktop \
    qml/ApiAccess.js \
    qml/pages/MapPage.qml \
    harbour-BusPaulo.png \
    qml/dbSptrans.sqlite \
    qml/pages/StopPage.qml \
    qml/pages/NewFavoriteDialog.qml \
    qml/pages/AddToFavoriteDialog.qml \
    qml/pages/BusesInMap.qml \
    qml/pages/ManageFavorites.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-BusPaulo-de.ts

HEADERS += \
    src/managedb.h

RESOURCES += \
    qml/res.qrc

