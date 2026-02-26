;nyquist plug-in
;version 4
;type process
;preview linear
;name "Brutal Bitcrusher"
;author "Juke32"
;release "2026-02-26"
;copyright "GPL v2 or later"
;about "Brutal Bitcrusher - A highly choppy, lo-fi bitcrusher effect.\nApplies direct bit depth reduction and downsample-and-hold rate reduction."

;; ---- CONTROLS -------------------------------------------------------
;control bitDepth "Bit Depth" int "bits" 8 1 16
;control rateRedux "Sample Rate Reduction" int " factor" 8 1 100
;control mixPercent "Mix" float "%" 50 0 100

;; ---- PARAMETERS -------------------------------------------------------
(setf mix (/ mixPercent 100.0))

;; ---- BIT DEPTH REDUCTION ---------------------------------------------
;; Reduces the bit depth of the signal
(defun crush-bits (sig bits)
  (let* ((levels (power 2 bits))
         (half-levels (/ levels 2.0)))
    ;; Quantize: x_scaled = x * (levels/2), x_q = round(x_scaled), x_out = x_q / (levels/2)
    (clip (mult (quantize (mult sig half-levels) (truncate levels)) (/ 1.0 half-levels)) 1)))

;; ---- SAMPLE AND HOLD -------------------------------------------------
;; Downsample by taking every Nth sample, and hold it for N samples
;; Uses snd-avg (which can take a step size) and snd-resample for the hold effect
(defun sample-and-hold (sig factor)
  (if (<= factor 1)
      sig
      (let* ((downsampled (snd-avg sig factor factor op-average))) ; decimate
        (snd-resamplev downsampled *sound-srate* (snd-const 1 0 *sound-srate* (get-duration 1)))))) ; hold via nearest-neighbor resample

;; ---- MAIN PROCESSING -------------------------------------------------
(defun process-channel (sig)
  (let* (;; 1. Bit depth reduction
         (bit-crushed (crush-bits sig bitDepth))
         ;; 2. Sample rate reduction (Sample and Hold)
         (rate-crushed (sample-and-hold bit-crushed rateRedux))
         ;; 3. Wet/Dry Mix
         (wet rate-crushed)
         (dry sig))
    (sum (mult dry (- 1.0 mix))
         (mult wet mix))))

;; ---- TOP-LEVEL OUTPUT ------------------------------------------------
(multichan-expand #'process-channel *track*)
