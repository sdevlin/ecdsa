from distutils.core import setup, Extension

module1 = Extension('fft',
                    sources = ['fft.c'],
                    libraries=['fftw3'],
                    include_dirs=['/usr/local/include'],
                    )

setup (name = 'PackageName',
       version = '1.0',
       description = 'This is a demo package',
       ext_modules = [module1])