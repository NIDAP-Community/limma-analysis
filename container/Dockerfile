ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667
FROM ${BASE_IMAGE}
WORKDIR /app
COPY R/ R/
COPY scripts/ scripts/
COPY schemas/ schemas/
COPY test_data/ test_data/
COPY module.yml renv.lock ./
RUN mkdir -p /data /output && useradd --create-home --uid 10001 --shell /usr/sbin/nologin limma && chown --recursive limma:limma /app /data /output
USER limma
ENTRYPOINT ["Rscript", "--vanilla", "/app/scripts/run_limma_analysis.R"]
CMD ["--help"]
