import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../presentation/widgets/modals/premium_modal.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  int _actionCounter = 0;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // ─────────────────────────────────────────────────────────────────────────
  // IDs de Producción (configurables vía --dart-define o reemplazando aquí)
  // ─────────────────────────────────────────────────────────────────────────
  static const String _prodAndroidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL',
    defaultValue: '',
  );
  static const String _prodIosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL',
    defaultValue: '',
  );
  static const String _prodAndroidRewarded = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED',
    defaultValue: '',
  );
  static const String _prodIosRewarded = String.fromEnvironment(
    'ADMOB_IOS_REWARDED',
    defaultValue: '',
  );
  static const String _prodAndroidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER',
    defaultValue: '',
  );
  static const String _prodIosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER',
    defaultValue: '',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // IDs de unidades de anuncio (Usa Producción en Release si están definidos,
  // y Test IDs oficiales de Google AdMob en Debug para evitar baneo de cuenta)
  // ─────────────────────────────────────────────────────────────────────────
  static String get interstitialAdUnitId {
    if (kIsWeb) return 'test-interstitial-web';
    if (Platform.isAndroid) {
      if (kReleaseMode && _prodAndroidInterstitial.isNotEmpty) {
        return _prodAndroidInterstitial;
      }
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isIOS) {
      if (kReleaseMode && _prodIosInterstitial.isNotEmpty) {
        return _prodIosInterstitial;
      }
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return 'test-interstitial';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return 'test-rewarded-web';
    if (Platform.isAndroid) {
      if (kReleaseMode && _prodAndroidRewarded.isNotEmpty) {
        return _prodAndroidRewarded;
      }
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    if (Platform.isIOS) {
      if (kReleaseMode && _prodIosRewarded.isNotEmpty) {
        return _prodIosRewarded;
      }
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'test-rewarded';
  }

  static String get bannerAdUnitId {
    if (kIsWeb) return 'test-banner-web';
    if (Platform.isAndroid) {
      if (kReleaseMode && _prodAndroidBanner.isNotEmpty) {
        return _prodAndroidBanner;
      }
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isIOS) {
      if (kReleaseMode && _prodIosBanner.isNotEmpty) {
        return _prodIosBanner;
      }
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'test-banner';
  }

  /// Indica si se debe mostrar el modal simulado como fallback (en Web o modo Debug).
  static bool get _allowSimulatedFallback => kIsWeb || !kReleaseMode;

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('Error inicializando AdMob: $e');
    }
  }

  void _loadInterstitialAd() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd fallo al cargar: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _loadRewardedAd() {
    if (kIsWeb) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd fallo al cargar: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Punto 1: Intersticial inteligente después de registrar gasto/ingreso/tarjeta/abono
  /// Control de frecuencia: Cada 3 acciones se muestra un anuncio (y en la 1ra en modo pruebas).
  Future<void> registerActionAndShowInterstitial(
    BuildContext context,
    bool isPremium, {
    VoidCallback? onAdClosed,
  }) async {
    // Si el usuario es VIP Premium, NUNCA mostrar anuncios intersticiales
    if (isPremium) {
      onAdClosed?.call();
      return;
    }

    _actionCounter++;
    final shouldShow = kReleaseMode
        ? (_actionCounter % 3 == 0)
        : (_actionCounter % 3 == 0 || _actionCounter == 1);

    if (!shouldShow) {
      onAdClosed?.call();
      return;
    }

    if (!kIsWeb && _interstitialAd != null) {
      final adToShow = _interstitialAd!;
      _interstitialAd = null;
      adToShow.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
      );
      await adToShow.show();
    } else if (_allowSimulatedFallback) {
      // En Web o Debug cuando aún no cargó AdMob, mostramos Modal Intersticial Simulada
      if (!context.mounted) {
        onAdClosed?.call();
        return;
      }
      await _showSimulatedInterstitialModal(context);
      onAdClosed?.call();
    } else {
      // En Release móvil si no hubo fill de AdMob, recargamos en segundo plano sin bloquear al usuario
      _loadInterstitialAd();
      onAdClosed?.call();
    }
  }

  /// Punto 2: Anuncio Bonificado (Rewarded) para ganar Puntos en la Tienda o ventajas
  Future<void> showRewardedAd(
    BuildContext context,
    bool isPremium, {
    required VoidCallback onRewardEarned,
  }) async {
    if (!kIsWeb && _rewardedAd != null) {
      final adToShow = _rewardedAd!;
      _rewardedAd = null;
      adToShow.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      await adToShow.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
    } else if (_allowSimulatedFallback) {
      // En Web o cuando no hay anuncio cargado en Debug, mostramos Modal de Video Bonificado Simulado
      if (!context.mounted) return;
      final completed = await _showSimulatedRewardedModal(context);
      if (completed == true) {
        onRewardEarned();
      }
    } else {
      _loadRewardedAd();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El video aún se está cargando. Intenta de nuevo en unos segundos.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showSimulatedInterstitialModal(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '📢 ANUNCIO PATROCINADO',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🚀', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text(
                      'Inversiones Inteligentes App',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Multiplica tus ahorros en 3 sencillos pasos',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    PremiumModal.show(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.crown,
                        color: Color(0xFFF59E0B),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Cansado de la publicidad?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Text(
                              'Toca aquí para actualizar a QUIVO Premium y navegar 100% sin anuncios.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuar a mi Finanza',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showSimulatedRewardedModal(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _SimulatedRewardedDialog(),
    );
  }
}

class _SimulatedRewardedDialog extends StatefulWidget {
  const _SimulatedRewardedDialog();

  @override
  State<_SimulatedRewardedDialog> createState() =>
      _SimulatedRewardedDialogState();
}

class _SimulatedRewardedDialogState extends State<_SimulatedRewardedDialog> {
  int _secondsLeft = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🎬 VIDEO RECOMPENSA',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (_secondsLeft == 0)
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.grey),
                    onPressed: () => Navigator.pop(context, true),
                  )
                else
                  Text(
                    '00:0$_secondsLeft',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF059669),
                    Color(0xFF10B981),
                    Color(0xFF34D399),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.gift, color: Colors.white, size: 54),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Patrocinador Oficial QUIVO!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _secondsLeft > 0
                        ? 'Espera $_secondsLeft seg para desbloquear tu recompensa'
                        : '🎉 ¡Listo! Recompensa desbloqueada.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _secondsLeft == 0
                    ? () => Navigator.pop(context, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _secondsLeft == 0
                      ? '🎁 RECLAMAR MI RECOMPENSA'
                      : 'REPRODUCIENDO VIDEO...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punto 3: Widget de Banner / Anuncio Nativo que se integra en Consejos Financieros
class AdBannerWidget extends StatefulWidget {
  final bool isPremium;
  const AdBannerWidget({super.key, required this.isPremium});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isPremium && !kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _bannerAd = null;
                _isLoaded = false;
              });
            }
          },
        ),
      )..load();
    }
  }

  @override
  void didUpdateWidget(covariant AdBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPremium && _bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPremium) return const SizedBox.shrink();

    if (!kIsWeb && _bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    if (!AdService._allowSimulatedFallback) {
      return const SizedBox.shrink();
    }

    // En Web o modo Debug mientras carga, Banner Nativo Simulado elegante (con acceso a Premium)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => PremiumModal.show(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    const Color(0xFF1E293B).withValues(alpha: 0.8),
                    const Color(0xFF0F172A).withValues(alpha: 0.9),
                  ],
                )
              : LinearGradient(colors: [Colors.blue[50]!, Colors.purple[50]!]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: Color(0xFF38BDF8),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PATROCINADO • QUITA ANUNCIOS CON PREMIUM',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asegura tu futuro con las mejores herramientas financieras 2026.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.externalLink, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
