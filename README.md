
# HistoBCAD

**HistoBCAD** is an open-source tool for visualizing and processing multi-level histopathology images. It leverages the [OpenSlide](https://openslide.org/) library for loading whole-slide images and utilizes the **Qt QML Map API** for efficient, tile-based visualization. The application also integrates machine learning-based image analysis tools and includes preliminary server-side functionality for user management and diagnostics.

## Screenshots


## Key Features

- **Deep Zoom Viewer**: Navigate and explore whole-slide images seamlessly with an efficient tile-based rendering approach using Qt QML Map API.
- **Multi-Level Image Support**: Load and visualize multi-resolution images supported by OpenSlide.
- **Machine Learning Integration**: Run image analysis using built-in machine learning algorithms. Future versions will support plugin-based extensibility.
- **User and Diagnostics Management (Incomplete)**: Prototype server-side features for login, registration, and diagnostic workflows.

---

## Installation

### Prerequisites
- Python 3.12
- Qt and PySide 6
- [OpenSlide](https://openslide.org/) library and Python bindings
- Additional Python dependencies (listed in `requirements.txt`)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/abrahampm/histobcad.git
   cd histobcad
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:
   ```bash
   python main.py
   ```

---

## Usage

1. **Load a Whole-Slide Image**: Use the Open file option to load `.svs`, `.ndpi`, or other supported formats.
2. **Navigate**: Pan, zoom, and explore slides interactively with the deep zoom interface.
3. **Analyze**: Apply built-in machine learning algorithms to selected image slices.
4. **Diagnostics (Optional)**: Access server-side features like creating and managing diagnostics (under development).

---

## Roadmap

- [ ] Decouple machine learning algorithms into a **plugin-based architecture**.
- [ ] Enhance server-side functionality and integrate it into the tool.
- [ ] Add support for custom plugins and community-contributed tools.
- [ ] Improve user experience with annotations, region selection, and multi-image comparison.

---

## Contributing

We welcome contributions from the community! Here's how you can help:
1. Fork the repository.
2. Create a branch for your feature or fix.
3. Submit a pull request with detailed notes about your changes.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Community

If you have questions, suggestions, or feature requests, please reach out:
- **GitHub Discussions**: Join the conversation [here](https://github.com/abrahampm/histobcad/discussions).
- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/abrahampm/histobcad/issues).

---

## Acknowledgments

- [OpenSlide](https://openslide.org/) for enabling multi-resolution image loading.
- Qt and PySide6 for providing a robust GUI framework.
- The broader open-source community for inspiring and supporting this project.

## Publications
https://www.researchgate.net/publication/366366158_HistoBCAD_Open-source_tool_for_breast_cancer_detection_in_histopathological_images

We hope this tool makes a positive contribution to the histopathology and digital pathology community!
