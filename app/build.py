# build.py
import os
import shutil
import subprocess
import sys
from pathlib import Path


def build_lambda():
    # Configurações
    build_dir = Path("build")
    dist_dir = Path("dist")
    lambda_zip = dist_dir / "lambda_function.zip"

    print("🚀 Iniciando build da Lambda...")

    # Limpar diretórios anteriores
    for dir in [build_dir, dist_dir]:
        if dir.exists():
            shutil.rmtree(dir)
        dir.mkdir()

    # Instalar dependências no diretório de build
    print("📦 Instalando dependências...")
    subprocess.run([
        sys.executable,
        "-m",
        "pip",
        "install",
        "-r",
        "requirements.txt",
        "--target",
        str(build_dir)
    ], check=True)

    # Copiar arquivo da lambda
    print("📄 Copiando arquivo da Lambda...")
    shutil.copy("lambda_function.py", build_dir)

    # Criar ZIP
    print("🗜️ Criando arquivo ZIP...")
    shutil.make_archive(
        str(dist_dir / "lambda_function"),
        'zip',
        build_dir
    )

    # Limpar build dir
    print("🧹 Limpando diretórios temporários...")
    shutil.rmtree(build_dir)

    zip_size = os.path.getsize(lambda_zip) / (1024 * 1024)
    print(f"✅ Build concluído! Tamanho do ZIP: {zip_size:.2f}MB")


if __name__ == "__main__":
    build_lambda()