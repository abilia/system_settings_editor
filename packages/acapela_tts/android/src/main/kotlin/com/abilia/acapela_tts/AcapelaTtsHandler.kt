package com.abilia.acapela_tts

import android.content.Context
import android.util.Log
import com.acapelagroup.android.tts.acattsandroid
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AcapelaTtsHandler(
    context: Context?,
    license: AcapelaLicense,
    voicePath: String,
) : acattsandroid.iTTSEventsCallback {
    companion object {
        private val TAG = AcapelaTtsHandler::class.java.simpleName

        init {
            System.loadLibrary("acattsandroid")
        }
    }

    /**
     * Data class to keep track of all parts of an Acapela license
     */
    class AcapelaLicense(val userId: Long, val password: Long, val license: String)

    /**
     * Interface to get notified about when the text speaker finish speaking.
     */
    interface OnTtsFinishedListener {
        fun onTextSpeakFinished()
    }

    private var mListener: OnTtsFinishedListener? = null
    var voice: String? = null
        private set
    private lateinit var mTts: acattsandroid
    private val mVoicePaths: Array<String> = arrayOf(voicePath)
    val downloadedVoices: List<String>
        get() {
            val voices: MutableList<String> = ArrayList()
            val availableVoices: Array<String> = mTts.getVoicesList(mVoicePaths)
            resetVoiceAfterGetVoiceList()
            for (i in availableVoices.indices) {
                val voiceStr = availableVoices[i]
                if (voiceStr.isNotEmpty()) {
                    val voice: Map<String, String> = mTts.getVoiceInfo(voiceStr)
                    if (voice["speaker"] != null) {
                        voices.add(
                            voice["speaker"]!!
                        )
                    }
                }
            }
            return voices
        }
    val speechRate: Float
        get() = mTts.speechRate.toFloat()

    private fun setSpeechRate(speechRate: Float) {
        if (isVoiceLoaded) {
            mTts.setSpeechRate(speechRate)
        }
    }

    val isSpeaking: Boolean
        get() = isVoiceLoaded && mTts.isSpeaking

    fun pause() {
        if (isVoiceLoaded) {
            mTts.pause()
        }
    }

    fun resume() {
        if (isVoiceLoaded) {
            mTts.resume()
        }
    }

    fun stop() {
        if (isVoiceLoaded) {
            mTts.stop()
        }
    }

    fun setVoice(call: MethodCall, result: MethodChannel.Result) {
        val voice: String? = call.argument("voice")
        val loadedVoice = setVoice(voice)
        result.success(loadedVoice != null)
    }

    /**
     * Attempts to set the desired voice but will fall back to other voice if not successful.
     * Returns the name of the loaded voice
     * or null if the load failed.
     */
    private fun setVoice(voice: String?): String? {
        Log.d(TAG, "Setting voice e '$voice'")
        if (voice != null && this.voice != voice) {
            val speechRate = mTts.speechRate
            val availableVoices: Array<String> = mTts.getVoicesList(mVoicePaths)
            var loaded = voice.isNotEmpty() && loadVoice(
                voice
            )
            var voiceToTry = 0
            while (!loaded && voiceToTry < availableVoices.size) {
                loaded = loadVoice(availableVoices[voiceToTry++])
            }
            if(loaded){
                mTts.setSpeechRate(speechRate.toFloat())
            } else {
                Log.d(TAG, "Failed to load any suitable voice")
            }
        }
        return this.voice
    }

    fun speak(call: MethodCall, result: MethodChannel.Result) {
        val text: String? = call.argument("text")
        if (text != null && isVoiceLoaded) {
            mTts.speak(text)
            mListener = object : OnTtsFinishedListener {
                override fun onTextSpeakFinished() {
                    result.success(true)
                }
            }
        } else if (text == null) {
            result.error("ARGUMENT", "No argument 'text' of type String provided", null)
        } else {
            result.error("VOICE", "No voice is set", null)
        }
    }

    fun setSpeechRate(call: MethodCall, result: MethodChannel.Result) {
        val speed: Double? = call.argument("speed")
        if (speed != null && isVoiceLoaded) {
            setSpeechRate(speed.toFloat())
            result.success(true)
        } else if (speed == null) {
            result.error("ARGUMENT", "No argument 'speed' of type Double provided", null)
        } else {
            result.error("VOICE", "No voice is set", null)
        }
    }

    override fun ttsevents(type: Long, param1: Long, param2: Long, param3: Long, param4: Long) {
        if (type == acattsandroid.EVENT_AUDIO_END.toLong()) {
            mListener?.onTextSpeakFinished()
        }
    }

    private fun loadVoice(voice: String?): Boolean {
        val errorCode: Int = mTts.load(voice, "")
        if (errorCode == 0) {
            this.voice = voice
            Log.d(TAG, "AcapelaTts: Successfully loaded voice '$voice'")
            return true
        }
        Log.d(TAG, "AcapelaTts: Failed to load voice '$voice'. Reason $errorCode")
        return false
    }

    private val isVoiceLoaded: Boolean
        get() = voice != null

    private fun resetVoiceAfterGetVoiceList() {
        // Call to mTts.getVoicesList unloads current voice
        val loadedVoice = voice
        voice = null
        if (loadedVoice != null) {
            setVoice(loadedVoice)
        }
    }

    init {
        try {
            mTts = acattsandroid(context, this, null)
            mTts.setLicense(license.userId, license.password, license.license)
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to initiate Acapela tts", e)
        }
    }
}