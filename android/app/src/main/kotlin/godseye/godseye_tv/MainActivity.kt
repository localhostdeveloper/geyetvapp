package godseye.tv

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {

    private val CHANNEL = "godseye.tv/pip"

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()
            enterPictureInPictureMode(params)
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod(
                "pipModeChanged",
                isInPictureInPictureMode
            )
        }
    }
}