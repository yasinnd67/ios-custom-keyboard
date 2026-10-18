import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Özel Klavye")
                        .font(.largeTitle.bold())
                    Text("Kurulum kontrolü")
                        .font(.title2.bold())
                    Text("Bu uygulama, klavye uzantısının iPhone'a düzgün kurulduğunu doğrulamak ve ayarlarına ulaşmak için ana uygulamadır.")
                    VStack(alignment: .leading, spacing: 8) {
                        Label("1. Ayarlar'ı açın", systemImage: "gear")
                        Label("2. Genel → Klavye → Klavyeler bölümüne girin", systemImage: "keyboard")
                        Label("3. Yeni Klavye Ekle → Özel Klavye seçin", systemImage: "plus.circle")
                        Label("4. Klavyeyi bir metin alanında deneyin", systemImage: "text.cursor")
                    }
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Gizlilik notu")
                        .font(.title3.bold())
                    Text("Bu temel sürüm, klavyede yazdığınız metinleri bir sunucuya göndermez. Düzeltme özelliği yerel ve sınırlı bir sözlük kullanır; gerçek AI düzeltmesi henüz bağlanmamıştır. Pano ve OTP işlemleri yalnızca klavyedeki ilgili düğmeye dokunduğunuzda yapılır.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Özel Klavye")
        }
    }
}
