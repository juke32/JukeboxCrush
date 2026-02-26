;nyquist plug-in
;version 4
;type process
;preview linear
;name "JukeboxCrush"
;author "Juke32"
;release "2026-02-26"
;copyright "GPL v2 or later"
;about "JukeboxCrush - A highly choppy, lo-fi bitcrusher effect.\nApplies direct bit depth reduction and downsample-and-hold rate reduction."

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
;; We use snd-avg for stepping, and snd-compose for holding steps.
(defun sample-and-hold (sig factor)
  (if (<= factor 1)
      sig
      (let* ((f (float factor))
             (step-rate (/ *sound-srate* f))
             ;; downsampled acts as the steps (1 sample every 'factor')
             (downsampled (snd-avg sig factor factor op-average)))
        ;; Resample back up to hold the values using a staircase control signal
        (control-srate-abs *sound-srate*
          (snd-compose downsampled
            (mult (/ 1.0 step-rate)
                  (quantize (pwl f len f) 1)))))))

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
