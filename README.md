# Özel Klavye — yeniden kurulmuş temel proje

Bu depo, doğru iOS proje yapısını kullanır: bir ana iOS uygulaması ve onun içine gömülen gerçek bir Custom Keyboard Extension hedefi. GitHub Actions, XcodeGen ile Xcode projesi üretir, gerçek iOS cihaz hedefi için derler, paketin Info.plist dosyalarını/binary'lerini kontrol eder ve en son IPA'yı oluşturur.

## Build çıktısı

GitHub Actions başarılı olduğunda `CustomKeyboard-IPA` adlı artifact indirilir. GitHub artifact indirmesi bir ZIP dosyasıdır; ZIP'in içinden `CustomKeyboard.ipa` dosyasını çıkarın ve bu `.ipa` dosyasını Sideloadly'ye verin. IPA, Sideloadly tarafından cihazınıza özel olarak yeniden imzalanmak üzere imzasız üretilir.

## iPhone'da etkinleştirme

1. Uygulamayı Sideloadly ile yükleyin.
2. Ayarlar → Genel → Klavye → Klavyeler → Yeni Klavye Ekle yolundan `Özel Klavye`yi ekleyin.
3. Pano ve OTP işlevleri için klavyede `Tam Erişim` gerekebilir. Bu izin, klavyeye yazdığınız içeriğe hassas erişim verebildiği için bilinçli etkinleştirilmelidir.

## Bu sürümde çalışan temel işler

- Türkçe QWERTY klavye, harf/simge düzeni, sayı satırı, boşluk, silme, satır sonu ve klavye değiştirme tuşu.
- Kullanıcının `Pano` düğmesine dokunmasıyla o anki panoyu alıp yerel geçmişte tutma; son 20 elle yakalanmış metni tekrar ekleme.
- Kullanıcının `OTP` düğmesine dokunmasıyla panoda 4–8 haneli sayısal kod bulup ekleme.
- `Düzelt` düğmesinde çok sınırlı yerel yazım dönüşümleri.

## Henüz tamamlanmamış özellikler

- Gerçek AI ile Türkçe/İngilizce cümle düzeltme ve bağlamsal kelime tahmini için güvenli bir HTTPS backend gerekir. API anahtarını IPA içine koymak güvenli değildir; bu temel sürüm gerçek bir AI servisine bağlanmaz.
- iOS, özel klavyelerin SMS veya Mail kutularını okuyup OTP yakalamasına izin vermez. OTP burada yalnızca kullanıcının düğmeye basarak eriştiği panodan algılanır.
- iOS kopyalama eylemlerinin tamamını özel klavyeye bildirmez. Pano geçmişi yalnızca kullanıcı `Pano` menüsünde açıkça metni yakaladığında güncellenir; sistem panosunun arka planda tam geçmişini tutmaz.

## Build doğrulamaları

Workflow, derlemeden sonra şunları doğrular: ana app ve `.appex` klasörlerinin varlığı, iki Info.plist dosyasının geçerliliği, `CFBundleDisplayName`, klavye uzantısı nokta tanımlayıcısı ve principal class, çalıştırılabilir dosyaların varlığı, ARM64 mimarisi ve IPA içindeki eklenti plist dosyası.
