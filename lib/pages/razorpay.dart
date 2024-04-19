// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

 
//   int value = 0;
//   late Razorpay razorpay;
 

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     razorpay.clear();
//   }

//   handlePaymentSuccess(PaymentSuccessResponse successResponse) {
//     print("${successResponse.paymentId} success");
//   }

//   handlePaymentFailed(PaymentFailureResponse successResponse) {
//     print("${successResponse.message} success");
//   }

//   handleExternalWallet(ExternalWalletResponse response) {
//     print(response.walletName);
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     razorpay = Razorpay();
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentFailed);
//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
//   }

  

      
       
       
       
            
//               var options = {
//                 'key': 'rzp_test_svyVVKvAUNFz78',
//                 'amount': 1000 * 100,
//                 'name': 'Neuflolearn',
//                 // 'description': 'Fine T-Shirt',
//                 'retry': {'enabled': true, 'max_count': 1},
//                 'send_sms_hash': true,
//                 'prefill': {
//                   'contact': '8888888888',
//                   'email': 'test@razorpay.com'
//                 },

//                 'external': {
//                   'wallets': ['paytm','gpay','phonepe']
//                 },
//                 'theme': {
//                   'color': '#F37254', // Customize the color theme
//                 },
//                 'image': 'https://play-lh.googleusercontent.com/pFR1ylYSiSrErlbk43Nnkzs1j9GgkEbkwz_cOZdpy_PVYlU2I-oOX8YaecQTwud7lyA=w480-h960-rw' // Customize the logo
//               };
//               try {
//                 razorpay.open(options);
//               } catch (e) {
//                 print(e);
//               }
            
            
        