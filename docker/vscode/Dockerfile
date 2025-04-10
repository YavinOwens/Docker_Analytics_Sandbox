FROM codercom/code-server:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \


# Create and switch to non-root user
USER coder

# Set up Python environment
RUN python3 -m venv /home/coder/venv
ENV PATH="/home/coder/venv/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir \


WORKDIR /home/coder/project

# Install VSCode Python extension
RUN code-server --install-extension ms-python.python


# Expose code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
