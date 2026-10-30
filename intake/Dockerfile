FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY intake/requirements.txt /app/intake/requirements.txt
RUN pip install --no-cache-dir --require-hashes -r intake/requirements.txt
COPY intake /app/intake
COPY scripts/prepare_setup.py /app/scripts/prepare_setup.py
COPY setup/form.html /app/setup/form.html
RUN useradd --create-home --uid 10001 intake
USER intake
EXPOSE 10000
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT:-10000} --workers 2 --threads 4 --timeout 30 'intake.app:create_app()'"]
