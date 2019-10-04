# Flutter WebView Issue demonstration support

This project is used as a support to demonstrate an issue encountered while using a WebView in some specific condition for a Flutter application

## Some context

For a specific business case (SCORM application), we need to start a web server from our dart application.

We need that server to display a provided zipped web application.

From that server, we render a static html page containing an iframe.

At that point, the structure is as follows :

```
/ (Documents - application root directory)
|-- www
    |-- index.html
    |-- archive (uncompressed)
```

The index.html file mainly contains an iframe targeting a page within the /www/archive (e.g: http://127.0.0.1:3000/archive/index.html) and some javascript code, enabling the page referenced by the iframe to run.

## The expected behaviour

1. The webview should display the referenced content (a page, with a play button)
2. When the play button is pressed, the media image is shown
3. When the media image is pressed, the media is displayed

## The encountered behaviour

1. The webview displays the referenced content (a page, with a play button)
2. When the play button is pressed, a fullscreen interaction is triggered, no media is displayed

We can close the me fullscreen but, the media image is not displayed, and it is impossible to play the media video.

## Workaround

It is actually possible to make the expected behaviour happen following these instructions.

1. When the page with the play button is displayed, press anywhere on screen, but avoid that button.
2. The fullscreen should be triggered. Close the fullscreen.
3. The start page should be still available. Now you can press the play button.

After executing these steps, you should be able to play the media as expected
