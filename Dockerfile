FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder
LABEL stage=builder

ARG demopath=demo
# Set exposed ports
ENV MIX_ENV=prod

# Cache elixir deps
ADD $demopath/deps ./
ADD $demopath/mix.exs $demopath/mix.lock ./
COPY ./lib ./lv_states/lib
COPY ./mix.exs ./lv_states/
COPY ./mix.lock ./lv_states/
COPY ./deps ./lv_states/deps


#RUN mix do deps.get, deps.compile
RUN mix do  deps.compile

# Same with npm deps
COPY $demopath/assets/package.json $demopath/assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

ADD ./$demopath .

RUN npm run --prefix ./assets deploy
RUN mix do compile, phx.digest

FROM bitwalker/alpine-elixir:latest

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

COPY --from=phx-builder /opt/app/_build /opt/app/_build
COPY --from=phx-builder /opt/app/priv /opt/app/priv
COPY --from=phx-builder /opt/app/config /opt/app/config
COPY --from=phx-builder /opt/app/lib /opt/app/lib
COPY --from=phx-builder /opt/app/deps /opt/app/deps
COPY --from=phx-builder /opt/app/lv_states /opt/app/lv_states
#COPY --from=phx-builder /opt/app/.mix /opt/app/.mix
COPY --from=phx-builder /opt/app/mix.* /opt/app/

# alternatively you can just copy the whole dir over with:
#COPY --from=phx-builder /opt/app /opt/app
# be warned, this will however copy over non-build files

USER default

