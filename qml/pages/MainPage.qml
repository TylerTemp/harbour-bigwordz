/*
  Copyright (C) 2014 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Amilcar Santos nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtSensors 5.0

Page {
	id: mainPage

	allowedOrientations: Orientation.All

	property bool isFullScreen: false

	property int wordsBoxHeight: 100
	property int wordsBoxWidth: 100

	onOrientationChanged: {
//		console.log("orientation changed: " + orientation + "; w: " + width + "; h: " + height)
		lazyUpdateWords.updateWidth = true
		lazyUpdateWords.updateHeight = true
		lazyUpdateWords.start()
		// some problems while editing and changing orienation thus force to close keyboard
		words.focus = true
	}


	SilicaFlickable {
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: "About"
				onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
			}
			MenuItem {
				text: "Settings"
				onClicked: {
					pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"))
				}
			}
			MenuItem {
				text: "Toogle Full Screen"
				onClicked: {
					wordsBox.toggleFullscreen()
					lazyUpdateWords.start()
				}
			}
		}

		PushUpMenu {
			MenuItem {
				text: "Stored Words"
				onClicked: {
					var page = pageStack.push(Qt.resolvedUrl("StoredWordsPage.qml"))
					page.textChanged.connect(function() {
						inputText.text = window.currentText
						column.updateWords()
					})
				}
			}
		}

		Column {
			id: column

			width: mainPage.width
			height: mainPage.height

			function updateWords() {
//				console.log("column.updateWords() - mainH: " + mainPage.height + "; mainPage.width: " + mainPage.width)
				if (isPortrait) {
					words.font.pixelSize = hiddenText.calcFontSize(480)
				} else {
					words.font.pixelSize = hiddenText.calcFontSize(520)
				}
				words.text = window.currentText
			}

			Component.onCompleted: {
				updateWords()
			}

			PageHeader {
				id: header1
				title: appname
			}

			MouseArea {
				id: doubleTapDetector
				property int clickHitX: -1
				property int clickHitY: -1
				enabled: window.tap2toggle
				anchors.fill: wordsBox
				onClicked: {
					if (clickHitX < 0) {
						// first click
						clickHitX = mouse.x
						clickHitY = mouse.y
						doubleTapTimeout.start()
						return
					}
					if (Math.abs(mouse.x - clickHitX) <= Theme.iconSizeLarge
							&& Math.abs(mouse.y - clickHitY) <= Theme.iconSizeLarge) {
						wordsBox.toggleFullscreen()
					}
					clickHitX = -1
					clickHitY = -1
				}
				Timer {
					id: doubleTapTimeout
					interval: 800 // ms
					running: false
					repeat: false
					onTriggered: {
						parent.clickHitX = -1
						parent.clickHitY = -1
					}
				}

				onEnabledChanged: {
					clickHitX = -1
				}
			}

			Rectangle {
				id: wordsBox
				width: wordsBoxWidth //parent.width
				height: wordsBoxHeight //width
				anchors.centerIn: parent
				color: window.backColor()

				function updateHeightOnEdit() {
//					console.log("wordsBox.updateHeightOnEdit() - orentation: " + orientation + "; rotation: " + rotation)
					if (isFullScreen) {
						return
					}
//					console.log("input y " + inputText.y + " header1++ " + (header1.y + header1.height + height))
					if (isPortrait) {
						if (inputText.y < (header1.y + header1.height + height)) {
							wordsBoxHeight = inputText.y - header1.y - header1.height
						} else {
							wordsBoxHeight = Screen.width
						}
						return
					}
					if (isLandscape) {
						wordsBoxHeight = Math.max(50, inputText.y - header1.y - header1.height)
//						console.log("wordsBoxHeight: " + wordsBoxHeight)
						return
					}
				}

				function updateHeight() {
//					console.log("wordsBox.updateHeight() - isFullScreen: " + isFullScreen)
					if (isFullScreen) {
						wordsBoxHeight = isLandscape ? Screen.width : Screen.height //mainPage.height
						return
					}
					if (isLandscape) {
						wordsBoxHeight = Math.max(50, inputText.y - header1.y - header1.height)
//						console.log("wordsBoxHeight: " + wordsBoxHeight)
						return
					}
					wordsBoxHeight = mainPage.width
				}

				function updateWitdh() {
					if (isFullScreen) {
						wordsBoxWidth = mainPage.width
						return
					}
					wordsBoxWidth = mainPage.width
//					console.log("wordsBox.updateWitdh() wordsBoxWidth: " + wordsBoxWidth)
				}

				function toggleFullscreen() {
					words.focus = true		// force to close keyboard
					isFullScreen = !isFullScreen
					header1.visible = !isFullScreen
					inputText.visible = !isFullScreen
					//updateHeight()
					lazyUpdateWords.updateWidth = true
					lazyUpdateWords.updateHeight = true
					lazyUpdateWords.start()
					if (isFullScreen) {
						storedWordsModel.storeCurrentText()
						// remove extra caracters from input
						if (inputText.text.lenght > window.currentText.length) {
							inputText.text = window.currentText
						}
					}
				}

				Component.onCompleted: {
					// initial update
					wordsBoxHeight = parent.width
					wordsBoxWidth = parent.width
				}

				Label {
					// actual displayed words
					id: words
					anchors.fill: parent
					wrapMode: Text.WordWrap
					color: window.textColor()
					font.bold: true
					lineHeight: 0.95 //TODO reduce more the lineHeight and center

					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			TextField {
				id: inputText
//				text: "The quick brown fox jumps over the lazy dog"
				text: "Hello"
				y : parent.height - height
				width: mainPage.width - x

				onYChanged: {
					if (isFullScreen) {
						// isFullScreen requested while editing...
						return
					}
//					console.log("inputText.onYChanged " + y)
					wordsBox.updateHeightOnEdit()
					lazyUpdateWords.start()		//column.updateWords()
				}

				onTextChanged: {
//					console.log("inputText.onTextChanged")
					if (text === window.currentText) {
						// skip updates...
						return
					}
					if (text.length > 80) {
						window.currentText = text.substring(0,80)
						color = 'red'
					} else {
						window.currentText = text
						color = Theme.primaryColor
					}

					column.updateWords()
				}

				Keys.onReturnPressed: words.focus = true
				Keys.onEnterPressed: words.focus = true

				Timer {
					// to prevent unnecessary calls to calcFontSize()
					property bool updateWidth: false
					property bool updateHeight: false
					id: lazyUpdateWords
					interval: 200
					running: false
					repeat: false
					onTriggered: {
//						console.log("lazyUpdateWords.onTriggered")
						if (updateWidth) {
							wordsBox.updateWitdh()
							updateWidth = false
						}
						if (updateHeight) {
							wordsBox.updateHeight()
							updateHeight = false
						}
						words.font.pixelSize = 1 // forces item position update
						column.updateWords()
					}
				}
			}

			Text {
				id: hiddenText
				visible: false
				font.bold: true
				//wrapMode: Text.WordWrap
				lineHeight: 0.95 //TODO reduce more the lineHeight and center


				function calcFontSize(startSize) {
					var h = wordsBox.height
					var w = wordsBox.width
					var size2 = startSize
					var testHW = (h + w) * 1.2

					hiddenText.text = window.currentText

					hiddenText.font.pixelSize = size2
					hiddenText.wrapMode = Text.NoWrap
//					console.log("w: " + w + ", h:" + h + ", w.y: " + words.y +	"  --- pw: " + hiddenText.paintedWidth + ", ph:" + hiddenText.paintedHeight + "; testHW=" + testHW)
					if (hiddenText.paintedWidth > w || hiddenText.paintedHeight > wordsBoxHeight) {
						hiddenText.wrapMode = Text.WordWrap
						hiddenText.width = w
//						console.log("pw2: " + hiddenText.paintedWidth + ", ph2:" + hiddenText.paintedHeight)

						while (hiddenText.paintedWidth >= w || hiddenText.paintedHeight >= h) {
							size2 = size2  - (hiddenText.paintedHeight + hiddenText.paintedWidth > testHW ? 40 : 8)
							hiddenText.font.pixelSize = size2
							if (size2 < 16) {
								break
							}
//							console.log("pixelSize: " + size2 + " painted W: " + hiddenText.paintedWidth + ", H: " + hiddenText.paintedHeight + "; w+h: " + (hiddenText.paintedHeight+hiddenText.paintedWidth))
						}
					}
					return size2
				}
			}
		}
	}

//	Accelerometer {
//		id: accel
//		active: true // window.useSensors
//		dataRate: 4
//		onReadingChanged: {
//			console.log("=====onReadingChanged=========; x:" + reading.x + "; y: " + reading.y + "; z: "+ reading.z);
//		}

//		Component.onCompleted: {
//			// TODO
//			console.log("availableDataRates: " + availableDataRates.length  + "; v0: " + availableDataRates[0].minimum + "; " + availableDataRates[0].maximum)
//			// from Jolla phone | availableDataRates length:1 ;...[0].minimum: 1;...[0].maximum: 1000
//		}
//	}
}

