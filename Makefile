build:


.PHONY: build pre-build clean


clean-all: clean
	cd cmdstan-old && git clean -dxf
	cd cmdstan-old/stan && git clean -dxf
	cd cmdstan-old/stan/lib/stan_math && git clean -dxf
	cd cmdstan-new && git clean -dxf
	cd cmdstan-new/stan && git clean -dxf
	cd cmdstan-new/stan/lib/stan_math && git clean -dxf

clean:
	@echo "clean"
	$(RM) benchmark-warfarin-new*
	$(RM) benchmark-warfarin-old*

benchmark-warfarin-%.stan : benchmark-warfarin.stan
	cp benchmark-warfarin.stan $@

benchmark-warfarin-% : benchmark-warfarin-%.stan
	cd cmdstan-$* && make ../$@

pre-build:
	cp local cmdstan-old/make/local
	cp local cmdstan-new/make/local

build: pre-build benchmark-warfarin-old benchmark-warfarin-new
	@echo "build"

