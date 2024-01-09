import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_lyricsAPIUrl: lyricsAPIUrl.text

    QQC2.TextField {
        id: lyricsAPIUrl 
        Layout.preferredWidth: 1000
        Kirigami.FormData.label: i18n("Lyrics API Url:")
        placeholderText: i18n("https://...")
    }
}
