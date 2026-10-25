ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667
FROM ${BASE_IMAGE}
WORKDIR /app
COPY R/ R/
COPY scripts/ scripts/
COPY entrypoint.R ./
COPY schemas/ schemas/
COPY test_data/ test_data/
COPY module.yml renv.lock ./
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.title="limma-analysis" \
      org.opencontainers.image.description="Portable Limma analysis component derived from OMIX" \
      org.opencontainers.image.source="https://github.com/NIDAP-Community/limma-analysis" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.base.name="ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667" \
      org.opencontainers.image.created="${BUILD_DATE}"
RUN mkdir -p /data /output && useradd --create-home --uid 10001 --shell /usr/sbin/nologin limma && chown --recursive limma:limma /app /data /output
USER limma
ENTRYPOINT ["Rscript", "--vanilla", "/app/entrypoint.R"]
CMD ["--help"]
