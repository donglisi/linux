obj-y += crypto.o
crypto-y := api.o cipher.o compress.o memneq.o

crypto_algapi-y += proc.o
crypto_algapi-y := algapi.o scatterwalk.o $(crypto_algapi-y)
obj-y += crypto_algapi.o

crypto_hash-y += ahash.o
crypto_hash-y += shash.o
obj-y += crypto_hash.o

dh_generic-y := dh.o
dh_generic-y += dh_helper.o

$(obj)/rsapubkey.asn1.o: $(obj)/rsapubkey.asn1.c $(obj)/rsapubkey.asn1.h
$(obj)/rsaprivkey.asn1.o: $(obj)/rsaprivkey.asn1.c $(obj)/rsaprivkey.asn1.h
$(obj)/rsa_helper.o: $(obj)/rsapubkey.asn1.h $(obj)/rsaprivkey.asn1.h

rsa_generic-y := rsapubkey.asn1.o
rsa_generic-y += rsaprivkey.asn1.o
rsa_generic-y += rsa.o
rsa_generic-y += rsa_helper.o
rsa_generic-y += rsa-pkcs1pad.o

$(obj)/sm2signature.asn1.o: $(obj)/sm2signature.asn1.c $(obj)/sm2signature.asn1.h
$(obj)/sm2.o: $(obj)/sm2signature.asn1.h

sm2_generic-y += sm2signature.asn1.o
sm2_generic-y += sm2.o

$(obj)/ecdsasignature.asn1.o: $(obj)/ecdsasignature.asn1.c $(obj)/ecdsasignature.asn1.h
$(obj)/ecdsa.o: $(obj)/ecdsasignature.asn1.h
ecdsa_generic-y += ecdsa.o
ecdsa_generic-y += ecdsasignature.asn1.o
crypto_acompress-y := acompress.o
crypto_acompress-y += scompress.o
cryptomgr-y := algboss.o testmgr.o

crypto_user-y := crypto_user_base.o
CFLAGS_wp512.o := $(call cc-option,-fno-schedule-insns)  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=79149
aegis128-y := aegis128-core.o

# Enable <arm_neon.h>
CFLAGS_aegis128-neon-inner.o += -isystem $(shell $(CC) -print-file-name=include)

CFLAGS_serpent_generic.o := $(call cc-option,-fsched-pressure)  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=79149
CFLAGS_aes_generic.o := $(call cc-option,-fno-code-hoisting) # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=83356
obj-y += crc32c_generic.o
CFLAGS_jitterentropy.o = -O0
KASAN_SANITIZE_jitterentropy.o = n
UBSAN_SANITIZE_jitterentropy.o = n
jitterentropy_rng-y := jitterentropy.o jitterentropy-kcapi.o

ecdh_generic-y += ecdh.o
ecdh_generic-y += ecdh_helper.o

$(obj)/ecrdsa_params.asn1.o: $(obj)/ecrdsa_params.asn1.c $(obj)/ecrdsa_params.asn1.h
$(obj)/ecrdsa_pub_key.asn1.o: $(obj)/ecrdsa_pub_key.asn1.c $(obj)/ecrdsa_pub_key.asn1.h
$(obj)/ecrdsa.o: $(obj)/ecrdsa_params.asn1.h $(obj)/ecrdsa_pub_key.asn1.h
ecrdsa_generic-y += ecrdsa.o
ecrdsa_generic-y += ecrdsa_params.asn1.o
ecrdsa_generic-y += ecrdsa_pub_key.asn1.o
crypto_simd-y := simd.o
