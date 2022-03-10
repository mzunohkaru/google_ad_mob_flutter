import 'package:flutter/material.dart';
import 'package:google_admob_sample/utils/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GoogleAdmob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  late InterstitialAd _interstitialAd;

  bool _isInterstitialAdReady = false;

  bool _isRewardedAdReady = false;

  RewardedAd? _rewardedAd;

  int counter = 0;

  int coin = 0;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
        // Change Banner Size According to Ur Need
        size: AdSize.mediumRectangle,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: (ad, LoadAdError error) {
          print("このロードに失敗しました Error Message : ${error.message}");
          _isBannerAdReady = false;
          ad.dispose();
        }),
        request: AdRequest())
      ..load();

      
    //Interstitial Ads
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          this._interstitialAd = ad;
          _isInterstitialAdReady = true;
        }, onAdFailedToLoad: (LoadAdError error) {
          print("このロードに失敗しました Error Message : ${error.message}");
        }));

    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        this._rewardedAd = ad;
        ad.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          setState(() {
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@false");
            _isRewardedAdReady = false;
          });
          _loadRewardedAd();
        });
        setState(() {
          //1度しか表示させないパターン
          // counter++;
          // print("@@@@@@@@@@@@@@@@@@@@@@@@@@@$counter");
          // if (counter == 1) {
          //   print("@@@@@@@@@@@@@@@@@@@@@@@@@@@true");
          //   _isRewardedAdReady = true;
          // }

          //報酬を得るパターン
          coin++;
          _isRewardedAdReady = true;
        });
      }, onAdFailedToLoad: (error) {
        print('このロードに失敗しました Error Message :  ${error.message}');
        setState(() {
          _isRewardedAdReady = false;
        });
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
    _interstitialAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Admob"),
        centerTitle: true,
        actions: [Text("コイン$coin")],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Banner広告
            if (_isBannerAdReady)
              SizedBox(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            const SizedBox(
              height: 80,
            ),
            //interstitial広告
            ElevatedButton(
                onPressed: _isInterstitialAdReady ? _interstitialAd.show : null,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("interstitial Ad"),
                )),
            _isRewardedAdReady
                //リワード広告
                ? ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('ヒントが必要ですか？'),
                            content: const Text('広告を見てヒントを得る'),
                            actions: [
                              TextButton(
                                child: Text('cancel'.toUpperCase()),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('ok'.toUpperCase()),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _rewardedAd?.show(
                                    onUserEarnedReward: (_, reward) {
                                      // QuizManager.instance.useHint();
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("ヒント"),
                  )
                : const Text("ヒントは足元"),
          ],
        ),
      ),
    );
  }
}
