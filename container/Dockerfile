# Repository-owned primary continuous-matrix Limma adapter. It intentionally
# contains no database, cloud, or OncoChat credentials.
ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667
FROM ${BASE_IMAGE}
WORKDIR /app
COPY R/ R/
COPY scripts/ scripts/
COPY entrypoint.R ./
COPY schemas/ schemas/
COPY test_data/ test_data/
COPY module.yml OMIX_MODULE_SOURCE.md renv.lock ./
RUN mkdir -p /data /output && useradd --create-home --uid 10001 --shell /usr/sbin/nologin limma && chown --recursive limma:limma /app /data /output
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.title="limma-analysis" \
      org.opencontainers.image.description="Portable Limma analysis component derived from OMIX" \
      org.opencontainers.image.source="https://github.com/NIDAP-Community/limma-analysis" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.base.name="ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667" \
      org.opencontainers.image.created="${BUILD_DATE}"
ENV LIMMA_ANALYSIS_IMAGE_REVISION=${VCS_REF} \
    LIMMA_ANALYSIS_OMIX_SOURCE_COMMIT=68d4811323e2dd997208076dd398cc9d68dae5a1 \
    LIMMA_ANALYSIS_BASE_IMAGE=ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667
USER limma
ENTRYPOINT ["Rscript", "--vanilla", "/app/entrypoint.R"]
CMD ["--help"]
