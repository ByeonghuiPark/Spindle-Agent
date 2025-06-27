#!/bin/bash
# MachineToolAgent + RAG + FreeCAD 통합 시스템 설치 스크립트

echo "🚀 MachineToolAgent + RAG + FreeCAD 통합 시스템 설치"
echo "================================================================"

# Python 버전 확인
python_version=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
echo "🐍 Python 버전: $python_version"

if (( $(echo "$python_version < 3.8" | bc -l) )); then
    echo "❌ Python 3.8 이상이 필요합니다."
    exit 1
fi

# 가상환경 생성 및 활성화
echo "📦 가상환경 생성 중..."
python3 -m venv venv
source venv/bin/activate

# 기본 패키지 업그레이드
echo "⬆️ pip 업그레이드..."
pip install --upgrade pip setuptools wheel

# PyTorch 설치 (CUDA 지원)
echo "🔥 PyTorch 설치 중..."
if command -v nvidia-smi &> /dev/null; then
    echo "🚀 NVIDIA GPU 감지됨 - CUDA 버전 설치"
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    echo "💻 CPU 버전 설치"
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

# Transformers 및 관련 패키지
echo "🤖 Transformers 설치 중..."
pip install transformers>=4.35.0
pip install accelerate
pip install bitsandbytes  # GPU에서 양자화 지원

# RAG 관련 패키지
echo "📚 RAG 시스템 패키지 설치 중..."
pip install chromadb>=0.4.0
pip install langchain>=0.1.0
pip install langchain-community
pip install sentence-transformers

# 문서 처리 패키지
echo "📄 문서 처리 패키지 설치 중..."
pip install pypdf2
pip install python-docx
pip install docx2txt
pip install unstructured[local-inference]

# 웹 인터페이스
echo "🌐 웹 인터페이스 패키지 설치 중..."
pip install gradio>=4.0.0

# 기타 유틸리티
echo "🛠️ 유틸리티 패키지 설치 중..."
pip install requests
pip install pathlib
pip install typing-extensions

# 선택적 패키지들
echo "🎨 선택적 패키지 설치 중..."
pip install matplotlib  # 시각화
pip install numpy       # 수치 계산
pip install pandas      # 데이터 처리

echo "✅ 패키지 설치 완료!"
echo ""
echo "================================================================"
echo "🔧 FreeCAD 설치 안내"
echo "================================================================"
echo "FreeCAD는 별도로 설치해야 합니다:"
echo ""
echo "Ubuntu/Debian:"
echo "  sudo apt update"
echo "  sudo apt install freecad"
echo ""
echo "macOS (Homebrew):"
echo "  brew install freecad"
echo ""
echo "Windows:"
echo "  https://www.freecad.org/downloads.php 에서 다운로드"
echo ""
echo "📝 FreeCAD 없이도 RAG와 AI 채팅 기능은 정상 작동합니다."
echo ""

# 디렉토리 구조 생성
echo "📁 디렉토리 구조 생성 중..."
mkdir -p documents
mkdir -p output
mkdir -p logs

# 예제 문서 생성
cat > documents/sample_spindle_guide.txt << 'EOF'
# 스핀들 설계 기본 가이드

## CNC 스핀들 주요 구성요소
1. 주축 (Main Shaft)
   - 재료: SCM440, S45C
   - 열처리: 담금질 + 템퍼링
   - 표면 거칠기: Ra 0.8μm 이하

2. 베어링 시스템
   - 전방 베어링: 각접촉볼베어링
   - 후방 베어링: 원통롤러베어링
   - 정밀도: P4급 (일반), P2급 (정밀)

3. 하우징 (Housing)
   - 재료: 주철 (FC250, FC300)
   - 가공 정밀도: IT7급
   - 열처리: 스트레스 릴리프

## 설계 기준
- L/D 비율: 2.0 - 4.0 (최적: 2.5)
- 최대 회전수: 베어링 한계의 80%
- 안전계수: 2.0 이상

## 가공 조건
- 알루미늄: 8000-12000 RPM
- 스틸: 3000-6000 RPM
- 스테인리스: 2000-4000 RPM
EOF

echo "✅ 예제 문서 생성 완료: documents/sample_spindle_guide.txt"

# 실행 스크립트 생성
cat > run_system.py << 'EOF'
#!/usr/bin/env python3
"""
MachineToolAgent + RAG + FreeCAD 통합 시스템 실행 스크립트
"""

import sys
import os

# 현재 디렉토리를 Python 경로에 추가
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from spindle_rag_system import main

if __name__ == "__main__":
    main()
EOF

chmod +x run_system.py

# 웹 실행 스크립트 생성
cat > run_web.py << 'EOF'
#!/usr/bin/env python3
"""
웹 인터페이스 실행 스크립트
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from spindle_rag_system import MachineToolAgentRAGSystem

if __name__ == "__main__":
    print("🌐 MachineToolAgent + RAG + FreeCAD 웹 인터페이스")
    
    system = MachineToolAgentRAGSystem()
    system.run_web_interface(
        share=False,  # True로 설정하면 공개 링크 생성
        port=7860
    )
EOF

chmod +x run_web.py

# 배치 실행 스크립트 (Windows용)
cat > run_system.bat << 'EOF'
@echo off
echo 🚀 MachineToolAgent + RAG + FreeCAD 시스템 시작

call venv\Scripts\activate
python run_system.py

pause
EOF

# 배치 웹 실행 스크립트 (Windows용)
cat > run_web.bat << 'EOF'
@echo off
echo 🌐 웹 인터페이스 시작

call venv\Scripts\activate
python run_web.py

pause
EOF

echo ""
echo "================================================================"
echo "🎉 설치 완료!"
echo "================================================================"
echo ""
echo "🚀 실행 방법:"
echo ""
echo "1. CLI 모드:"
echo "   source venv/bin/activate"
echo "   python run_system.py"
echo ""
echo "2. 웹 인터페이스:"
echo "   source venv/bin/activate" 
echo "   python run_web.py"
echo "   브라우저에서 http://localhost:7860 접속"
echo ""
echo "3. Windows 사용자:"
echo "   run_system.bat  (CLI 모드)"
echo "   run_web.bat     (웹 모드)"
echo ""
echo "📄 예제 문서가 documents/ 폴더에 준비되어 있습니다."
echo ""
echo "💡 처음 실행 시 MachineToolAgent 모델 다운로드에 시간이 걸릴 수 있습니다."
echo "   (약 3-4GB, 4bit 양자화 적용)"
echo ""
echo "🔧 문제 발생 시:"
echo "   - GPU 메모리 부족: 모델 로딩 실패 시 CPU 모드로 전환됩니다"
echo "   - FreeCAD 오류: 3D 모델링 없이도 RAG와 채팅 기능은 작동합니다"
echo "   - 네트워크 오류: 프록시 환경에서는 HuggingFace 접근이 제한될 수 있습니다"
echo ""
echo "================================================================"