import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_apiURL: apiURL.text
    property alias cfg_rounding: rounding.value

    QQC2.TextField {
        id: apiURL 
        Layout.preferredWidth: 1000
        Kirigami.FormData.label: i18n("Lyrics API Url:")
        placeholderText: i18n("https://...")
    }

    QQC2.SpinBox {
        id: rounding 
        from: 0
        to: 5000
        stepSize: 5
        Kirigami.FormData.label: i18n("Display next line x ms before:")
    }
}
