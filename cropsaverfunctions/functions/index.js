const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");


admin.initializeApp();
const db = admin.firestore();


exports.checkFarmers = functions.region("europe-west3").runWith({ timeoutSeconds: 540, memory: '2GB' })
    .pubsub.schedule('20 21 * * *')
    .timeZone("Europe/Istanbul")
    .onRun(async () => {
        var fetch = require("node-fetch");
        var query = db.collection("farmers").where("myLocation.name", "!=", null);
        var farmers = await query.get();
        for (let i = 0; i < farmers.docs.length; i++) {
            if (farmers.docs[i].data().myCrops != null) {
                var minHeats = [];
                var humanDates = [];
                var url = "https://api.openweathermap.org/data/2.5/onecall?lat=" + farmers.docs[i].data().myLocation.lat + "&lon=" + farmers.docs[i].data().myLocation.long + "&appid="Your Open Weather API "&units=metric&lang=en&exclude=minutely,hourly";              
                fetch(url)
                    .then(async function (data) {
                        var map = await data.json();
                        for (let x = 0; x < 3; x++) {
                            minHeats.push(map.daily[x].temp.min); 
                            var dateObject = new Date(map.daily[x].dt * 1000);
                            var humanDateFormat = dateObject.toLocaleString();
                            humanDateFormat = humanDateFormat.substring(0, 11);
                            humanDates.push(humanDateFormat);        
                        }  
                        if (minHeats.length > 0) {
                            for (var j = 0; j < minHeats.length; j++) {
                                for (var k = 0; k < farmers.docs[i].data().myCrops.length; k++) {
                                    if (minHeats[j] < farmers.docs[i].data().myCrops[k].minHeat) {                                       
                                        if(farmers.docs[i].data().language.toString().trim()==="tr"){
                                            await admin.messaging().sendToDevice(farmers.docs[i].data().deviceToken, 
                                            {
                                                data: {
                                                    crop: farmers.docs[i].data().myCrops[k].name,
                                                    date: humanDates[j],
                                                },                                
                                                notification: {
                                                    title: "Ürünleriniz Tehlikede",
                                                    image: farmers.docs[i].data().myCrops[k].url,
                                                    body:  farmers.docs[i].data().myLocation.name+" Konumunuzda "+humanDates[j] +" Günü " + farmers.docs[i].data().myCrops[k].tr+" Ürününüz İçin Don Tehlikesi Tespit Ettik.",
                                                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                                                    priority: "high",
                                                    sound: "default"
                                                },
                                            });        
                                            let transporter = nodemailer.createTransport({
                                                host: "smtp.eu.mailgun.org",
                                                port: 587,
                                                secure: false,
                                                auth: {
                                                    user: "emin@cropsaver.me",
                                                    pass: "Your mailgun password",
                                                },
                                            });
                                            let info = await transporter.sendMail({
                                                from: '"CropSaver" <emin@cropsaver.me>',
                                                to: farmers.docs[i].data().email,
                                                subject: "Ürünleriniz İçin Potansiyel Tehlike",
                                                text: `Merhaba ${farmers.docs[i].data().userName}
                                    
${farmers.docs[i].data().myLocation.name} Lokasyonundaki ${farmers.docs[i].data().myCrops[k].tr} Ürünün İçin ${humanDates[j]} Günü Don Tehlikesi Tespit ettik.
                                    
Dona karşı önlemleri CropSaver Makaleler kısmından görebilirsiniz. Ürünleriniz ile ilgili bir sorunuz varsa tarım uzmanına sorabilirsiniz.
                                    
Ürün kayıpları ve israfı konusunda daha dikkatli olalım. Herşey dünyamız için.
                                            
Saygılarımızla.
                                    
                                                `
                                            }).catch(function (err) {
                                                console.log("ERROR Notification MAİL TR --> " + err);
                                            });
                                        }else{
                                            await admin.messaging().sendToDevice(farmers.docs[i].data().deviceToken,
                                             {
                                                data: {
                                                    crop: farmers.docs[i].data().myCrops[k].name,
                                                    date: humanDates[j],
                                                },                                
                                                notification: {
                                                    title: "Your Crops In Danger",
                                                    image: farmers.docs[i].data().myCrops[k].url,
                                                    body: "In Your "+farmers.docs[i].data().myLocation.name+" Location On " + humanDates[j] + " We Identified A Potential Frost Hazard For Your " + farmers.docs[i].data().myCrops[k].name,
                                                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                                                    priority: "high",
                                                    sound: "default"
                                                },
                                            });
                                            let transporter = nodemailer.createTransport({
                                                host: "smtp.eu.mailgun.org",
                                                port: 587,
                                                secure: false,
                                                auth: {
                                                    user: "emin@cropsaver.me",
                                                    pass: "Your Mailgun password",
                                                },
                                            });
                                            let info = await transporter.sendMail({
                                                from: '"CropSaver" <emin@cropsaver.me>',
                                                to: farmers.docs[i].data().email,
                                                subject: "Potential Hazards To Your Crops",
                                                text: `Hi ${farmers.docs[i].data().userName}
                                    
We Identified A Potential Frost Hazard For Your ${farmers.docs[i].data().myCrops[k].name} In Your ${farmers.docs[i].data().myLocation.name} Location On ${humanDates[j]}
                                    
You can see measures against frost from CropSaver articles. If you have some problems with your crops you can ask them to agriculture experts.
                                    
Let's become more aware of crop losses and waste. We have only one world...
                                            
Best Regards.
                                    
                                                `
                                            }).catch(function (err) {
                                                console.log("ERROR Notification MAİL EN --> " + err);
                                            });
                                        }

                                        
                                    }

                                }
                            }

                        } else {
                            console.log("ERROR minHeats null");
                            return;
                        }
                    }).catch(function (err) { console.log("ERRORRR ---> " + err) });
            }
        }
    })


exports.sendWelcomeEmail = functions.region("europe-west3").firestore.document("farmers/{uid}")
.onCreate(async (snapshot,context) => {
    var {uid}=context.params;

    let info = await transporter.sendMail({
        from: '"CropSaver" <emin@cropsaver.me>',
        to: snapshot.data().email,
        subject: "Welcome to CropSaver",
        text: `Hi ${snapshot.data().userName}

Welcome to CropSaver.
        
My name is Muhammed Emin. I'm the developer of CropSaver.
        
What is CropSaver and why we created it?
        
Worldwide, an estimated 20-40% of crop yield is lost to weather conditions. Losses of staple cereal and tuber crops directly impact food security and nutrition, while losses in key commodity crops have major impacts on both household livelihoods and national economies. Crop-based disaster prevention and preparedness are the keys to build resilient livelihoods and help eradicate hunger, food insecurity, and malnutrition.CropSaver is a crop-based early weather notification application for your crops. You can choose your crops from the application and your crop's location easily. We will compare your crop's critical heats and weather conditions and we will notify you. Be sure to open your notification settings.
        
Let's become more aware of crop losses and waste. We have only one world...
        
Best Regards.`
    }).catch(function (err) {
        console.log("ERROR WELCOME MAİL --> " + err);
    });

});




