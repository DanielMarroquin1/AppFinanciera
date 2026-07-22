import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  int _actionCounter = 0;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // IDs de unidades de anuncio de PRUEBA oficiales de Google AdMob
  static String get interstitialAdUnitId {
    if (kIsWeb) return 'test-interstitial-web';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return 'test-interstitial';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return 'test-rewarded-web';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    return 'test-rewarded';
  }

  static String get bannerAdUnitId {
    if (kIsWeb) return 'test-banner-web';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return 'test-banner';
  }

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

  /// Punto 1: Intersticial inteligente después de registrar gasto/ingreso/tarjeta
  /// Control de frecuencia: Cada 3 acciones se muestra un anuncio.
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
    // Mostramos anuncio cada 3 acciones (o en la primera si está en pruebas para que el usuario verifique en vivo)
    if (_actionCounter % 3 != 0 && _actionCounter != 1) {
      onAdClosed?.call();
      return;
    }

    if (!kIsWeb && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
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
      await _interstitialAd!.show();
    } else {
      // En Web o cuando no hay anuncio cargado, mostramos Modal Intersticial Simulada
      if (!context.mounted) {
        onAdClosed?.call();
        return;
      }
      await _showSimulatedInterstitialModal(context);
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
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
    } else {
      // En Web o cuando no hay anuncio cargado, mostramos Modal de Video Bonificado Simulado
      if (!context.mounted) return;
      final completed = await _showSimulatedRewardedModal(context);
      if (completed == true) {
        onRewardEarned();
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
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '📢 ANUNCIO ADMOB TEST',
                      style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Multiplica tus ahorros en 3 sencillos pasos',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿Cansado de la publicidad?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                          const Text('Actualiza al Plan Premium VIP y navega 100% libre de anuncios.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continuar a mi Finanza', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showSimulatedRewardedModal(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int secondsLeft = 3;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(seconds: 1), () {
              if (ctx.mounted && secondsLeft > 0) {
                setDialogState(() => secondsLeft--);
              }
            });

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🎬 VIDEO RECOMPENSA ADMOB',
                            style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                        ),
                        if (secondsLeft == 0)
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: Colors.grey),
                            onPressed: () => Navigator.pop(ctx, true),
                          )
                        else
                          Text(
                            '00:0$secondsLeft',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), fontSize: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
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
                            '¡Patrocinador Oficial Finanzas App!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            secondsLeft > 0
                                ? 'Espera $secondsLeft seg para reclamar tus +50 Puntos'
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
                        onPressed: secondsLeft == 0 ? () => Navigator.pop(ctx, true) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          secondsLeft == 0 ? '🎁 RECLAMAR MI RECOMPENSA' : 'REPRODUCIENDO VIDEO...',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          onAdLoaded: (_) => setState(() => _isLoaded = true),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
          },
        ),
      )..load();
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

    // Si está en Web o mientras carga/o sin llenar, Banner Nativo Simulado elegante
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(colors: [const Color(0xFF1E293B).withValues(alpha: 0.8), const Color(0xFF0F172A).withValues(alpha: 0.9)])
            : LinearGradient(colors: [Colors.blue[50]!, Colors.purple[50]!]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.sparkles, color: Color(0xFF38BDF8), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('PATROCINADO • ADMOB TEST', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.amber)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Asegura tu futuro con las mejores tasas de inversión 2026.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.externalLink, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
