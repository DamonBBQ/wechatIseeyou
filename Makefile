.PHONY: build build-m2 clean

build::
	swift build -c release --arch arm64 --arch x86_64
	cp -f .build/out/Products/Release/wechattweak ./wechattweak

build-m2::
	swift build -c release --arch arm64
	@bin_dir="$$(swift build -c release --arch arm64 --show-bin-path)"; \
	cp -f "$$bin_dir/wechattweak" ./wechattweak-m2

clean::
	rm -rf .build
	rm -f wechattweak wechattweak-m2
