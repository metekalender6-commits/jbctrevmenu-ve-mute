# JB Mute + CT Revive (CS2 SourceMod)

CS2 Jailbreak sunucuları için:
- T takımının sesli konuşmasını otomatik kapatır (yazı chat'e dokunmaz), admin `!unmute` ile açabilir.
- CT takımına round başına paylaşımlı **revive (canlandırma)** hakkı verir. Hak bitmeden hiçbir CT ölmez; hak bittikten sonraki ölümcül vuruş normal şekilde öldürür ve round doğal akışına döner.
- Revive anında 3 saniyelik dokunulmazlık (god mode) ve bildirim sesi.

## Komutlar (hepsi `css/generic` yetkisi ister)

| Komut | Açıklama |
|---|---|
| `!mute <hedef>` | Hedefin sesini kapatır |
| `!unmute <hedef>` | Hedefin sesini açar (T bile olsa serbest bırakır) |
| `!ctrev0` | Kalan CT revive hakkını round bitene kadar sıfırlar |

## Cvar

| Cvar | Varsayılan | Açıklama |
|---|---|---|
| `sm_ctrev_max` | `3` | Round başına CT takımının toplam paylaşımlı revive hakkı |

## Kurulum (elle)

1. `addons/sourcemod/scripting/jb_ctrev_mute.sp` dosyasını sunucunda derle (`spcomp`) **veya** Releases sekmesinden hazır `.smx` dosyasını indir.
2. Üretilen `jb_ctrev_mute.smx` dosyasını `addons/sourcemod/plugins/` klasörüne at.
3. Sunucuyu yeniden başlat veya `sm plugins load jb_ctrev_mute` yaz.

## Otomatik derleme (GitHub Actions)

Bu repo [SourceKnight](https://github.com/maxime1907/sourceknight) kullanır. `main` dalına her push'ta `.github/workflows/build.yml` otomatik olarak:
1. `.sp` dosyasını derler,
2. Derlenmiş `.smx` dosyasını Actions çıktısı (Artifacts) olarak ekler,
3. Yeni bir GitHub Release oluşturup `.smx` dosyasını ekler.

Elle derleme yapmak istemiyorsan, push sonrası **Releases** sekmesinden en güncel `.smx` dosyasını indirip doğrudan sunucuna atman yeterli.

## Notlar / Bilinen sınırlamalar

- CS2'nin SourceMod desteği hâlâ geliştirme aşamasında olduğundan, `EmitSoundToAll`, `SetListenOverride` gibi bazı native'lerin davranışı sunucunun kullandığı SourceMod/Metamod build'ine göre değişebilir. Sorun yaşarsan güncel bir SourceMod CS2 snapshot'ı kullandığından emin ol.
- Bildirim sesi (`friends/friend_online.wav`) genel bir Source motoru sesidir; kendi sunucunda çalmıyorsa `.sp` dosyasındaki `REVIVE_SOUND` tanımını sunucunda kayıtlı geçerli bir ses yoluyla değiştir.
- God mode süresi `.sp` içindeki `GOD_DURATION` sabiti ile ayarlanır (varsayılan 3.0 saniye).
