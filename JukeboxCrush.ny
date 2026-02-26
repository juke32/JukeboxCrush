;nyquist plug-in
;version 4
;type process
;preview linear
;name "JukeboxCrush"
;author "Juke32"
;release "2026-02-26_1"
;copyright "GPL v2 or later"
;debugbutton false
;about "JukeboxCrush - Retro Bitcrusher\nCombines bit depth reduction, zero-order hold\nresampling, mu-law quantization, foldback distortion,\nricher noise palette, and vintage presets.\nBy Juke32. GPL v2 or later."

;; =====================================================
;; JukeboxCrush - Definitive Retro Bitcrusher
;; Combines the best of:
;;   - BitCrusher.ny (Steve Daulton's abs-quantize)
;;   - audacity_bitcrush_v3 / v4 (ZOH staircase array method)
;;   - RetroDegrade.ny (mu-law, TPDF dither, noise types, presets)
;;   - JukeboxCrush_fixed.ny (foldback, drive, quantmode, presets)
;;   - RetroJukeCrush.ny (clean architecture, mono mix)
;; =====================================================
;; Features:
;;   - Bit depth reduction 1-16 bits (Steve Daulton abs-quantize)
;;   - 3 quantization modes: Standard, Mu-law, Hard Clip
;;   - TPDF dither
;;   - Sample rate reduction with 2 ZOH modes:
;;       Fast ZOH  (snd-compose staircase - audacity_bitcrush_v4)
;;       Array ZOH (bad-resample dot-clock - from v3 / RetroJukeCrush)
;;   - Rate jitter for vinyl / tape wobble feel
;;   - Foldback distortion for harmonic richness
;;   - Drive / pre-gain saturation
;;   - Pre and Post low-pass filters
;;   - Noise beds: None, White, Pink, Hum 50 Hz, Hum 60 Hz, Hiss
;;   - Mono mix
;;   - Dry / Wet mix
;;   - 12 vintage system presets + Custom
;; =====================================================

;; ---- CONTROLS -------------------------------------------------------

;control preset    "Preset"         choice "Custom,NES (2A03),GameBoy,Atari 2600,C64 SID,MSX,ZX Spectrum,Apple II,8-bit PC,SNES,Early Mac,Amstrad,Phone,AM Radio,VHS,Lo-Fi Punch" 0
;control bits      "Bit Depth"      int    "bits"       8     1   16
;control sourcerate "Sample Rate"   int    "Hz"     22050  1000 44100
;control zohmode   "ZOH Mode"       choice "Fast (snd-compose),Array (dot-clock)" 0
;control jitter    "Rate Jitter"    float  "%"          0     0   10
;control foldback  "Foldback"       int    "%"          0     0  100
;control quantmode "Quantize Mode"  choice "Standard,Mu-law,Hard Clip" 0
;control dither    "Dither"         choice "Off,TPDF On" 0
;control drive     "Drive"          int    "%"        100     0  200
;control prelp     "Pre Low-Pass"   int    "Hz (0=off)"  0     0 20000
;control postlp    "Post Low-Pass"  int    "Hz (0=off)"  0     0 20000
;control noiseType "Noise Type"     choice "None,White,Pink,Hum 50 Hz,Hum 60 Hz,Hiss" 0
;control noiseLevel "Noise Level"   float  "%"          0     0  100
;control mono      "Output"         choice "Stereo,Mono Mix" 0
;control mix       "Dry/Wet"        float  "%"        100     0  100

;; ---- PRESETS ---------------------------------------------------------
(defun apply-preset (p)
  (cond
    ((= p  1) (setf bits  7 sourcerate 15720 zohmode 0 jitter 0.5 foldback 30 quantmode 0 dither 0 drive 100 prelp 14000 postlp 10500 noiseType 0 noiseLevel  0 mono 0 mix 100))  ; NES 2A03
    ((= p  2) (setf bits  4 sourcerate  8192 zohmode 1 jitter   0 foldback 50 quantmode 0 dither 0 drive 120 prelp  8000 postlp  4000 noiseType 1 noiseLevel  3 mono 0 mix 100))  ; GameBoy
    ((= p  3) (setf bits  4 sourcerate  8000 zohmode 1 jitter 1.5 foldback 70 quantmode 2 dither 0 drive 140 prelp  6000 postlp  3900 noiseType 1 noiseLevel  8 mono 0 mix 100))  ; Atari 2600
    ((= p  4) (setf bits  8 sourcerate 15600 zohmode 0 jitter 0.2 foldback 20 quantmode 0 dither 0 drive 110 prelp 14000 postlp 12000 noiseType 0 noiseLevel  2 mono 0 mix 100))  ; C64 SID
    ((= p  5) (setf bits  8 sourcerate 17897 zohmode 0 jitter 0.3 foldback 40 quantmode 0 dither 0 drive 120 prelp  9000 postlp  8000 noiseType 0 noiseLevel  3 mono 0 mix 100))  ; MSX
    ((= p  6) (setf bits  1 sourcerate 22050 zohmode 1 jitter   0 foldback 60 quantmode 2 dither 0 drive 150 prelp 10000 postlp  7000 noiseType 1 noiseLevel  5 mono 0 mix 100))  ; ZX Spectrum
    ((= p  7) (setf bits  1 sourcerate 11025 zohmode 1 jitter   0 foldback 50 quantmode 2 dither 0 drive 130 prelp  5000 postlp  4800 noiseType 0 noiseLevel  4 mono 0 mix 100))  ; Apple II
    ((= p  8) (setf bits  8 sourcerate 11025 zohmode 0 jitter   0 foldback 10 quantmode 0 dither 0 drive 100 prelp  7000 postlp  6000 noiseType 0 noiseLevel  0 mono 0 mix 100))  ; 8-bit PC
    ((= p  9) (setf bits  8 sourcerate 32000 zohmode 0 jitter   0 foldback  0 quantmode 0 dither 1 drive 100 prelp 20000 postlp 16000 noiseType 0 noiseLevel  1 mono 0 mix 100))  ; SNES
    ((= p 10) (setf bits  8 sourcerate 22254 zohmode 0 jitter 0.2 foldback 20 quantmode 0 dither 1 drive 110 prelp 12000 postlp 10000 noiseType 0 noiseLevel  2 mono 0 mix 100))  ; Early Mac
    ((= p 11) (setf bits  8 sourcerate 11025 zohmode 0 jitter 0.3 foldback 40 quantmode 0 dither 0 drive 120 prelp  7000 postlp  5500 noiseType 0 noiseLevel  3 mono 0 mix 100))  ; Amstrad
    ((= p 12) (setf bits  8 sourcerate  8000 zohmode 1 jitter   0 foldback  0 quantmode 0 dither 1 drive 100 prelp  4000 postlp  3400 noiseType 0 noiseLevel  0 mono 1 mix 100))  ; Phone
    ((= p 13) (setf bits  8 sourcerate 11025 zohmode 0 jitter 0.5 foldback  0 quantmode 0 dither 0 drive 100 prelp  6000 postlp  4500 noiseType 3 noiseLevel  5 mono 1 mix 100))  ; AM Radio
    ((= p 14) (setf bits 12 sourcerate 24000 zohmode 0 jitter 0.8 foldback  0 quantmode 0 dither 1 drive 100 prelp 18000 postlp 11000 noiseType 5 noiseLevel  3 mono 0 mix 100))  ; VHS
    ((= p 15) (setf bits  6 sourcerate 12000 zohmode 0 jitter 0.3 foldback 25 quantmode 0 dither 1 drive 130 prelp 10000 postlp  8000 noiseType 2 noiseLevel  4 mono 0 mix 100)))) ; Lo-Fi Punch

(when (> preset 0) (apply-preset preset))

;; ---- UNIT CONVERSIONS ------------------------------------------------
(setf mix        (/ mix        100.0))
(setf noiseLevel (/ noiseLevel 100.0))
(setf foldback   (/ foldback   100.0))

;; ---- HELPER: clamp ---------------------------------------------------
(defun jc-clamp (x lo hi) (max lo (min hi x)))

;; ---- FILTER HELPERS --------------------------------------------------
(defun lowpass-safe (sig hz)
  ;; Avoid filtering if disabled or above Nyquist
  (if (or (<= hz 0) (>= hz (* 0.49 *sound-srate*)))
      sig
      (lowpass8 sig hz)))

;; ---- NOISE GENERATOR -------------------------------------------------
(defun pinkify (sig)
  ;; Simple pink noise approximation via cascaded lowpass
  (scale 0.7 (sum (lowpass8 sig 800)
                  (scale 0.5 (lowpass8 sig 2000))
                  (scale 0.25 sig))))

(defun jc-hum (freq)
  (let* ((f1 (osc freq))
         (f2 (scale 0.3 (osc (* 2 freq))))
         (f3 (scale 0.15 (osc (* 3 freq)))))
    (scale 0.4 (sum f1 f2 f3))))

(defun jc-hiss ()
  (highpass8 (noise) 5000))

(defun make-noise-bed (ntype)
  (cond
    ((= ntype 1) (noise))
    ((= ntype 2) (pinkify (noise)))
    ((= ntype 3) (jc-hum 50))
    ((= ntype 4) (jc-hum 60))
    ((= ntype 5) (jc-hiss))
    (t           (scale 0 (noise)))))

;; ---- BIT REDUCTION ---------------------------------------------------
;; Steve Daulton's abs-quantize method (from BitCrusher.ny):
;; Correctly handles all integer bit depths 1-16 without offset errors.
(defun abs-quantize (sig bits)
  (let ((steps (power 2 bits)) factor offset)
    (setf sig    (clip sig 1))
    (setf steps  (round (1- steps)))
    (setf sig    (sum 1 sig))
    (setf factor (/ (- steps 1.0) steps))
    (setf offset (/ factor 2.0))
    (if (> steps 1)
        (setf sig (mult 0.5 sig factor))
        (setf sig (mult 0.5 sig)))
    (setf sig (quantize sig steps))
    (if (> steps 1)
        (mult (/ 2.0 factor) (sum (- offset) sig))
        sig)))

;; Mu-law encode / decode (standard 255-mu telephone compander)
(defun mu-encode (x)
  (let* ((mu 255.0)
         (ax (abs x)))
    (mult (if (> x 0) 1 -1)
          (/ (log (1+ (* mu ax))) (log (1+ mu))))))

(defun mu-decode (y)
  (let* ((mu 255.0)
         (ay (abs y)))
    (mult (if (> y 0) 1 -1)
          (/ (- (expt (1+ mu) ay) 1) mu))))

(defun quant-mu (sig bits)
  (let* ((enc     (mu-encode sig))
         (crushed (abs-quantize enc bits)))
    (mu-decode crushed)))

;; TPDF dither: two independent noise sources (unbiased triangular PDF)
(defun tpdf-dither (bits)
  (scale (/ 1.0 (* (power 2 bits) 2.0))
         (sum (noise) (noise))))

;; Unified quantization with mode and optional dither
(defun apply-quant (sig b mode dith)
  (let* ((d    (if (= dith 1) (tpdf-dither b) 0))
         (sig2 (sum sig d)))
    (case mode
      (1 (quant-mu    sig2 b))          ; Mu-law
      (2 (clip (scale 1.2 (abs-quantize sig2 b)) 1)) ; Hard Clip
      (t (abs-quantize sig2 b)))))      ; Standard (default)

;; ---- SAMPLE RATE REDUCTION -------------------------------------------

;; MODE 0: Fast ZOH using snd-compose staircase (from audacity_bitcrush_v4)
;; Creates a quantized time map that holds each sample for 'factor' output samples.
(defun fast-zoh (sig factor)
  (let ((f (max 1.0 factor)))
    (control-srate-abs *sound-srate*
      (let ((sig2 (mult (/ *sound-srate*)
                        (quantize (pwl f len f) 1))))
        (snd-compose sig sig2)))))

;; MODE 1: Array ZOH - the original "bad-resample" dot-clock approach
;; (from audacity_bitcrush_v3 and RetroJukeCrush.ny.old)
;; Works by filling an array with repeated copies of each fetched sample.
(defun fill-array-zoh (s-a sig times)
  (let ((count 0)
        (total (/ (length s-a) times)))
    (dotimes (i total)
      (let ((next (snd-fetch sig)))
        (dotimes (j times)
          (setf (aref s-a (+ j (* i times))) next))))))

(defun array-zoh (sig factor)
  (let* ((num    (max 1 (truncate factor)))
         (size   1000)
         (dur    (get-duration 1))
         (output (s-rest 0)))
    (dotimes (count (truncate (/ dur size)))
      (let ((s-array (make-array (* num size))))
        (fill-array-zoh s-array sig num)
        (setf output
          (sim output
               (at-abs (/ (* count num size) *sound-srate*)
                 (cue (snd-from-array 0 *sound-srate* s-array)))))))
    (let ((rem-samples (rem (truncate dur) size)))
      (when (> rem-samples 0)
        (let ((end-array (make-array (* num rem-samples))))
          (fill-array-zoh end-array sig num)
          (setf output
            (sim output
                 (at-abs (/ (* (truncate (/ dur size)) (* num size)) *sound-srate*)
                   (cue (snd-from-array 0 *sound-srate* end-array))))))))
    output))

;; Main sample-rate crusher: jitter + foldback + chosen ZOH mode
(defun crush-rate (sig target-hz jitter-pct)
  (let* (;; Base rate, clamped away from Nyquist
         (base (jc-clamp target-hz 500 (* 0.92 *sound-srate*)))
         ;; Static jitter per run (random deviation, feels like tape/vinyl wow)
         (jittered (if (> jitter-pct 0)
                       (let* ((r   (- (random 1000) 500))
                              (pct (* jitter-pct (/ r 500.0))))
                         (* base (+ 1 pct)))
                       base))
         ;; Foldback: add amplitude-modulated harmonic overtone for grit
         (folded (if (> foldback 0)
                     (sum sig
                          (scale foldback
                                 (mult sig (sine (hz-to-step 440)))))
                     sig))
         ;; Downsampling factor
         (factor (/ *sound-srate* jittered)))
    ;; Choose ZOH mode
    (if (= zohmode 1)
        (array-zoh folded factor)
        (fast-zoh  folded factor))))

;; ---- MONO MIX --------------------------------------------------------
(defun to-mono (sig)
  (if (<= (length sig) 1)
      sig
      (let* ((a (aref sig 0))
             (b (aref sig 1))
             (m (scale 0.5 (sum a b))))
        (vector m m))))

;; ---- MAIN PER-CHANNEL PROCESSING ------------------------------------
(defun process-channel (sig)
  (let* (;; 1. Drive / pre-gain saturation
         (driven (if (> drive 100)
                     (clip (scale (/ drive 100.0) sig) 1)
                     sig))
         ;; 2. Pre low-pass (band-limit before crushing)
         (pre-filtered (lowpass-safe driven prelp))
         ;; 3. Sample rate reduction (ZOH)
         (rate-crushed (if (/= sourcerate *sound-srate*)
                           (crush-rate pre-filtered sourcerate jitter)
                           pre-filtered))
         ;; 4. Bit depth reduction + quantization + dither
         (quantized (apply-quant rate-crushed bits quantmode dither))
         ;; 5. Post low-pass (smooth harsh aliases)
         (post-filtered (lowpass-safe quantized postlp))
         ;; 6. Add noise bed
         (with-noise (if (> noiseLevel 0)
                         (sum post-filtered
                              (scale noiseLevel (make-noise-bed noiseType)))
                         post-filtered))
         ;; 7. Output level compensation (drive boost re-normalised)
         (out (clip (scale (/ 100.0 (max drive 100)) with-noise) 1)))
    out))

;; ---- TOP-LEVEL OUTPUT ------------------------------------------------
(let* ((proc (multichan-expand #'process-channel *track*))
       ;; Optional mono downmix after per-channel processing
       (final (if (= mono 1) (to-mono proc) proc)))
  (sim (mult mix       final)
       (mult (- 1 mix) *track*)))

;; End of JukeboxCrush
